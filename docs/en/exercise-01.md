# Exercise 1 – Getting the engine running

> **Prerequisite:** Exercise 0 is complete (the core flow exists at the business level).
> **Working directory:** `services/process-application`
> **New in this exercise:** Operaton starter, engine configuration, embedded database (H2), auto-deployment, Cockpit, H2 console, `act_*` tables, start form, Manual Task, EnterpriseGlue The Bridge (optional additional UI).

## What this is about

Before you automate the core flow from Exercise 0, you get the engine running once. For that a
deliberately tiny excerpt is ready: a start form for the registration data, followed by two
**Manual Tasks** "Confirm" and "Send welcome mail". The engine simply runs through Manual Tasks, so
without a single line of code you get an instance that runs all the way through. From Exercise 2
on you build the placeholders out into real steps.

## Learning goals

After this exercise you can

- get a Spring Boot module with an embedded Operaton engine up and running,
- find your way around the Cockpit between Processes, Tasklist and Admin,
- map the `act_*` tables to the categories Repository, Runtime and History,
- start an instance via a **start form** and explain why it doesn't stop at **Manual Tasks**.

## Target model

![BPMN model of the exercise](../assets/exercise-01.svg)

The model sits ready at `services/process-application/src/main/resources/bpmn/membership.bpmn`.
You don't model anything in this exercise.

## The task

### 1. Enable the dependencies

In `services/process-application/pom.xml`, uncomment the `TODO Exercise 1` block with the two
Operaton starters (`webapp` and `rest`). To do so, delete only the lines `<!--` and `-->`
between `<!-- @exercise-1:begin … -->` and `<!-- @exercise-1:end -->`. Keep the markers; the
`load-solution` task needs them.

### 2. Enable the configuration

In `src/main/resources/application.yaml`, uncomment the `TODO Exercise 1` block. It contains:

- the connection to an H2 database in the file `~/.operaton-training/exercise` (user `sa`,
  empty password),
- the **H2 console**, an SQL interface in the browser,
- the Cockpit admin user (`admin` / `admin`).

Without the block the application still starts, but on a throwaway in-memory H2: no admin user, no
H2 console, and all data is gone after a restart.

> **Term: embedded database.** A database that runs as a library in the same process as the
> application instead of as a separate server. You install nothing: H2 creates the file on the first
> start, and the engine creates its `act_*` tables in it by itself. Because H2 writes to a file, the
> data survives a restart.

### 3. Arm the application

In `TrainingApplication.java`, enable the annotations `@SpringBootApplication` and
`@EnableJpaRepositories`. Then auto-configuration and auto-deployment kick in: all `*.bpmn` files
under `src/main/resources` are deployed into the engine at startup.

### 4. Start the application

Start the application and watch in the log how the engine comes up and deploys the model:

```bash
cd services/process-application && ../../mvnw spring-boot:run
```

### 5. Look at the engine's tables

Open [http://localhost:8080/h2-console](http://localhost:8080/h2-console), replace the pre-filled
value `jdbc:h2:~/test` in the **JDBC URL** field with `jdbc:h2:file:~/.operaton-training/exercise`
and click **Connect** with user `sa` and an empty password. These five tables are the most
important:

| Table | Prefix | Content |
|---|---|---|
| `act_re_procdef` | `re` = Repository | deployed **process definitions** (`subscribeNewsletter`) |
| `act_ru_execution` | `ru` = Runtime | **running** process instances |
| `act_ru_task` | `ru` | open **User Tasks** |
| `act_ru_variable` | `ru` | **process variables** of running instances |
| `act_hi_procinst` | `hi` = History | **completed** process instances |

Check with this query whether your model was deployed:

```sql
SELECT key_, name_, version_ FROM act_re_procdef;
```

### 6. Explore the Cockpit

Open [http://localhost:8080/operaton/app/cockpit/](http://localhost:8080/operaton/app/cockpit/)
(admin / admin). Under **Processes** you see `Join Inner Circle`, the display name for the
process key `subscribeNewsletter`. Click your way through **Cockpit**, **Tasklist** and **Admin**.

### 7. Play through the process

In the **Tasklist**, start an instance via **Start process** → `Join Inner Circle`. The Tasklist
shows a **start form** with `email`, `name` and `age`. Fill it in and start. The instance runs
without stopping to the end; afterwards it shows as `COMPLETED` in `act_hi_procinst`, and `act_ru_*`
is empty.

> **Term: start form (Generated Form).** The fields sit as `camunda:formData` on the Start
> Event. The Tasklist renders a form from them; the entered values become process
> variables.

> **Term: Manual Task.** A task the engine neither executes nor waits at, a placeholder for
> "something happens here later".

### 8. Optional: Connect EnterpriseGlue The Bridge

The Bridge is an additional web UI for the engine, complementary to the Cockpit. None of the
exercises depends on it. It is the only part of the training that needs Docker: the containers are
described by `stack/docker-compose.yml`. Bring them up in a second terminal; the application keeps
running in the first one:

```bash
cd stack && docker-compose up -d
```

1. Open [http://localhost:8081](http://localhost:8081) and log in with the dev admin
   (`admin@enterpriseglue.com` / `adminadmin`).
2. Register the engine under **Platform settings → Engines → Add engine**:

   | Field | Value |
   |---|---|
   | Engine name | `Training` (free choice) |
   | Engine product | `Operaton` |
   | How EnterpriseGlue connects | `Connect directly to the engine` |
   | Endpoint URL | `http://host.docker.internal:8080/engine-rest` |
   | Endpoint authentication | `Username and password` → Username `admin`, Password `admin` |
   | Environment label | `Dev` (preselected) |

   Leave everything else at its defaults. The endpoint URL is the same REST API the Cockpit uses.
   From inside the container the host is reachable via `host.docker.internal`, not via `localhost`.
3. After **Create**, the engine shows **Connected**, and `Join Inner Circle` appears under
   **Mission Control**.

> **Term: EnterpriseGlue The Bridge.** An additional UI for the engine (model, deploy and manage
> BPMN/DMN). It speaks the same `engine-rest` API as the Cockpit. The training engine ignores the
> credentials, but the Bridge only stores a directly connected engine with credentials, hence
> `admin`/`admin` from `application.yaml`.

## Constraints

- The business layer of the hexagonal architecture already exists in the module, but is commented out.
- All modules run on port `8080` and use the same H2 file. Always start only one at a time; the
  running application locks the file.
- You only need Docker for the optional step 8 (Bridge).

## Expected result

The log shows `Auto-Deploying resources: [... membership.bpmn]` and `Started TrainingApplication`.
`Join Inner Circle` appears in the Cockpit under **Processes**, and a started instance runs to the
End Event.

## Self-check

- [ ] Dependencies, configuration and `@SpringBootApplication` are enabled
- [ ] The application starts, `act_re_procdef` contains `subscribeNewsletter`
- [ ] `Join Inner Circle` appears in the Cockpit under **Processes**
- [ ] An instance started via the start form shows as `COMPLETED` in the History
- [ ] You can explain why the instance doesn't wait at the Manual Tasks
- [ ] Optional: after connecting, the Bridge at `http://localhost:8081` shows `Join Inner Circle`

## Hints

- If the Cockpit shows the **Operaton Setup** page for creating an initial user instead of the
  login, the block in `application.yaml` is still commented out (the log shows `jdbc:h2:mem:…`
  instead of the H2 file). Don't create a user there; uncomment the block and start again.
- `Database may be already in use: "…/.operaton-training/exercise.mv.db"`: another application is
  running on the same file. Stop it. For the same reason, external database tools can't open the
  file while the application is running.
- For a clean slate, stop the application and delete `~/.operaton-training` (Windows:
  `%USERPROFILE%\.operaton-training`).
- **Bridge (step 8):** If `docker logs enterpriseglue-backend` shows
  `Engine base URL must use HTTPS when endpoint policy is enforced` when you save the engine, the
  backend runs without the `EG_ENGINE_*` variables from `stack/docker-compose.yml`; run
  `cd stack && docker-compose up -d` again. `Engine base URL private host must have an exact
  endpoint-policy allowlist entry` means `localhost` was entered instead of `host.docker.internal`.
- **Bridge (step 8):** If `docker-compose up -d` stops with
  `container enterpriseglue-backend is unhealthy` and the log shows a failed migration (e.g.
  `column "user_id" does not exist`), the Bridge volumes stem from an older image. Reset them or
  apply `stack/enterpriseglue-ledger-baseline-v0.19.2.sql` once; both recipes are in that file's
  header.

## Reference solution

`../../solutions/exercise-01/` – or load it directly:

```bash
./mvnw -pl services/process-application antrun:run@load-solution -Dsolution=01
```

The task backs up your state under `services/process-application/.load-solution-backup/` and sets
`src/` and `pom.xml` to the state after Exercise 1. Then reload the Maven project in IntelliJ.

## Next step

In Exercise 2 the placeholders become a real User Task and a Service Task.

➡️ [Next: Exercise 2](exercise-02.md)
