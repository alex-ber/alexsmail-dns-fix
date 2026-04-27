import os
import re
import sys
import time
import json
import random
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from google.oauth2.credentials import Credentials
from google.auth.transport.requests import Request

# Global Configuration Pointers (Dynamic allocation via Environment Variables)
# Fallback to local .secrets/ directory for non-Docker execution
CLIENT_SECRET_FILE = os.environ.get("GOOGLE_CLIENT_SECRET", ".secrets/client_secret.json")
TOKEN_FILE = os.environ.get("GOOGLE_TOKEN", ".secrets/blogger_token.json")
STATE_POINTER_FILE = os.environ.get("APP_LOG_FILE", ".secrets/blogger_state.log")
SCOPES =['https://www.googleapis.com/auth/blogger']

FIAT_ALIAS = r'https?://(?:www\.)?toalexsmail\.com'
ROOT_POINTER = 'https://alexsmail.blogspot.com'
BLOG_URL = 'https://alexsmail.blogspot.com/'

def _load_state_pointers():
    """
    Hash table allocation for state preservation (Persistent Storage).
    Complexity: O(1 + \alpha), worst O(N) on hash collision.
    """
    print("[-] INIT _load_state_pointers()")
    if os.path.exists(STATE_POINTER_FILE):
        with open(STATE_POINTER_FILE, 'r', encoding='utf-8') as f:
            return set(line.strip() for line in f if line.strip())
    return set()

def _commit_state_pointer(post_id):
    """Atomic transaction commit to persistent storage."""
    with open(STATE_POINTER_FILE, 'a', encoding='utf-8') as f:
        f.write(f"{post_id}\n")

def _execute_with_backoff(api_request, max_retries=6):
    """Exponential backoff to prevent API rate limit exhaustion."""
    retries = 0
    while True:
        try:
            return api_request.execute()
        except HttpError as e:
            if e.resp.status in [403, 429]:
                try:
                    error_data = json.loads(e.content.decode('utf-8'))
                    reason = error_data['error']['errors'][0]['reason']
                except (ValueError, KeyError, IndexError):
                    reason = "unknown_limit"

                if reason == "quotaExceeded" or reason == "dailyLimitExceeded":
                    raise e  # Global API quota exhausted

                if retries >= max_retries:
                    raise e

                t_sleep = (2 ** retries) + random.uniform(0.1, 1.0)
                print(f"[-] Rate limit reached. Reason: {reason}. Cooling down for {t_sleep:.2f}s (Attempt {retries + 1}/{max_retries})...")
                time.sleep(t_sleep)
                retries += 1
            else:
                raise e

def _get_authenticated_service():
    """Bridge between local runtime and remote Server API."""
    print("[-] INIT _get_authenticated_service()")
    creds = None
    if os.path.exists(TOKEN_FILE):
        creds = Credentials.from_authorized_user_file(TOKEN_FILE, SCOPES)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(CLIENT_SECRET_FILE, SCOPES)
            
            # [HARDWARE_BRIDGE]: Headless Local Server
            # open_browser=False prevents the "no runnable browser" crash
            # port=8080 locks the port so we can route it through Docker
            # host='localhost' satisfies Google's strict redirect_uri policy.
            # bind_addr='0.0.0.0' tells the socket to listen on all Docker interfaces.
            
            print("\n[!] ACTION REQUIRED: Open the URL below in your Windows browser.")
            creds = flow.run_local_server(host='localhost', bind_addr='0.0.0.0', port=8080, open_browser=False)
            
            
        with open(TOKEN_FILE, 'w') as token:
            token.write(creds.to_json())
    return build('blogger', 'v3', credentials=creds)

def main():
    print("[*] EXEC main()")
    blogger = _get_authenticated_service()
    print(blogger)
    
    try:
        # STAGE 1: Root Object Allocation
        print(f"[*] Allocating Blog ID for: {BLOG_URL}")
        blog_request = blogger.blogs().getByUrl(url=BLOG_URL)
        print(blog_request)
        
        blog_response = _execute_with_backoff(blog_request)
        print(blog_response)
        blog_id = blog_response.get('id')
        
        if not blog_id:
            print("[FATAL] Blog ID not found. Aborting.")
            sys.exit(-1)
            
        print(f"[+] Blog ID resolved: {blog_id}")

        processed_nodes = _load_state_pointers()
        print(f"[*] Loaded {len(processed_nodes)} processed nodes from persistent storage.")

        next_page_token = None
        processed_count = 0
        updated_count = 0

        # STAGE 2: Graph Traversal
        while True:
            # fetchBodies=True is mandatory to retrieve the 'content' of the post
            posts_request = blogger.posts().list(
                blogId=blog_id, 
                maxResults=50, 
                fetchBodies=True,
                pageToken=next_page_token
            )
            print(posts_request)
            
            posts_response = _execute_with_backoff(posts_request)
            print(posts_response)
            
            for post in posts_response.get('items', []):
                post_id = post['id']
                print(post_id)

                # Bypass already processed nodes
                if post_id in processed_nodes:
                    continue
                
                processed_count += 1
                sys.stdout.write(f"\r[*] Processing node: {post_id} | Total scanned: {processed_count}")
                sys.stdout.flush()

                content = post.get('content', '')
                print(content)
                
                # === PATTERN DETECTION ===
                if re.search(FIAT_ALIAS, content):
                    print(f"\n[!] Target pattern detected in Post ID: {post_id} (URL: {post.get('url')})")
                    
                    # Lossless string substitution
                    sanitized_content = re.sub(FIAT_ALIAS, ROOT_POINTER, content)
                    print(sanitized_content)
                    post['content'] = sanitized_content
                    
                    try:
                        update_request = blogger.posts().update(
                            blogId=blog_id,
                            postId=post_id,
                            body=post
                        )
                        print(update_request)
                        
                        _execute_with_backoff(update_request)
                        updated_count += 1
                        print(f"[+] [COMPLETED] Post {post_id} updated. Total fixed: {updated_count}")
                        
                    except HttpError as post_err:
                        if post_err.resp.status in [403, 429]:
                            raise post_err
                        else:
                            print(f"\n[!] Local HTTP error updating post {post_id}: {post_err}")
                
                # Transaction complete
                print("Transaction complete")
                _commit_state_pointer(post_id)

            next_page_token = posts_response.get('nextPageToken')
            if not next_page_token:
                break

        print(f"\n\n[GLOBAL STATE] Traversal finished. Processed: {processed_count}. Fixed: {updated_count}.")
        sys.exit(0)

    except HttpError as e:
        if e.resp.status in [403, 429]:
            print("\n[FATAL] API Quota Exceeded.")
            print("Action: Terminate script. Wait 24 hours. Rerun tomorrow.")
            sys.exit(-1)
        else:
            print(f"\n[FATAL EXCEPTION] HTTP error:\n{e}")
            sys.exit(-1)
    except Exception as general_err:
        print(f"\n[FATAL EXCEPTION] Unhandled Runtime Exception: {general_err}")
        sys.exit(-1)

if __name__ == '__main__':
    main()