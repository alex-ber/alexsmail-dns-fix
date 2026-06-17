```markdown
# Running Docker Compose Services Sequentially

To force Docker Compose to run services not simultaneously (as it does by default), but **strictly one after another**, you use the `depends_on` block with a special condition: `condition: service_completed_successfully`.

Here's how it looks in practice.

## Example: A Chain of 3 Steps

Let's imagine you have 3 sequential scripts: downloading data, processing it, and generating a report.

Let's create a `docker-compose.yml`:

```yaml
services:
  # Step 1
  step1-download:
    image: my-app-image
    command: python download_data.py
    # The container will exit after the script completes

  # Step 2
  step2-process:
    image: my-app-image
    command: python process_data.py
    depends_on:
      step1-download:
        condition: service_completed_successfully # Wait for Step 1 to complete successfully

  # Step 3
  step3-report:
    image: my-app-image
    command: python generate_report.py
    depends_on:
      step2-process:
        condition: service_completed_successfully # Wait for Step 2 to complete successfully
```

---

## How to Control This (Solving Your Problem)

Now Docker Compose knows about the dependency graph (Step 1 → Step 2 → Step 3). You can control the execution very flexibly:

### 1. Run the Entire Chain

You simply run the regular command:

```bash
docker compose up
```

**What will happen:** Docker will start `step1`. Steps 2 and 3 will be in a waiting state. As soon as the script in `step1` exits with code `0` (success), `step2` will automatically start, followed by `step3`.

### 2. Run a Specific Process TOGETHER with Its Prerequisites

Let's say you only want to go up to the second step (processing).

```bash
docker compose up step2-process
```

**What will happen:** Docker will see that `step2` requires `step1`. It will start `step1-download`, wait for it to complete, start `step2-process`, and then **stop** (step 3 will not be started).

### 3. Run ONLY One Specific Process (Without the Chain)

If you already downloaded the data yesterday, and now you've changed the processing script (Step 2), you don't want to run Step 1 again. You can run *only* Step 2, ignoring the dependencies.

Use the `--no-deps` flag or the `run` command for this:

```bash
# Option A: using run (often more convenient for one-off scripts)
docker compose run --no-deps step2-process

# Option B: using up
docker compose up --no-deps step2-process
```

**What will happen:** Docker will ignore the `depends_on` block and immediately run only the `step2-process` container.

---

## Tip: Using Profiles

If these scripts are just helper utilities, and you have your main application (database, web server) running in the same `docker-compose.yml`, you can hide these "steps" from the standard `docker compose up` command so they don't run every time.

To do this, add `profiles` to them:

```yaml
services:
  step1-download:
    image: my-app-image
    command: python download_data.py
    profiles: ["pipeline"] # Assign a profile
```

Then the regular `docker compose up` will only start the server and database, and you can run your chain like this:

```bash
docker compose --profile pipeline up
```
```
