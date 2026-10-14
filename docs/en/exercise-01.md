# Exercise 1 – Getting the engine running

> **Prerequisite:** Exercise 0 is complete (the target process exists at the business level).
> **Working directory:** `services/process-application`
> **New in this exercise:** Operaton starter, engine configuration, embedded database (H2), auto-deployment, Cockpit, H2 console, `act_*` tables, start form, Manual Task, EnterpriseGlue The Bridge (optional additional UI).

## What this is about

In Exercise 0 you modeled the **complete target process** of the Inner Circle. Before anyone
automates the whole flow, an external consultant roughed out a **deliberately tiny first
excerpt**: a start form for the registration data, followed by two **Manual Tasks** –
"Confirm" and "Send welcome mail". Manual Tasks are placeholders: the engine simply runs
through them. That way you get a process instance that runs from start to finish – without a
single line of code.

This mini-version is **not** the target process and **not** the target model. It exists only
to get the engine running once and to get a feel for deployment, execution, and the data. From
Exercise 2 on you build the placeholders out into real steps, one at a time.

What's still missing is the **runtime environment**: a Spring Boot module in which the Operaton
engine runs. That's exactly what you'll set up now.

## Learning goals

After this exercise you can

- get a Spring Boot module with an embedded Operaton engine up and running,
- name what the engine needs in order to start (database, auto-configuration, auto-deployment),
- find your way around the Cockpit between Processes, Tasklist, and Admin,
- map the `act_*` tables to the categories Repository, Runtime, and History,
- start an instance from the Tasklist via a **start form**,
- explain why an instance made up of nothing but **Manual Tasks** runs through without stopping.

## Target model

![BPMN model of the exercise](../assets/exercise-01.svg)

This is the deliberately reduced excerpt: start form → Manual Task "Confirm" → Manual Task
"Send welcome mail" → End. It sits ready at
`services/process-application/src/main/resources/bpmn/membership.bpmn`. You won't model anything
in this exercise – you'll bring it to life.

## The task

> This is about **setting up and getting familiar** – no business code.

### 1. Enable the dependencies

Open `services/process-application/pom.xml` and uncomment the `TODO Exercise 1` block: the two
Operaton starters (`webapp` and `rest`). Only with these are the engine, the Cockpit webapp,
and the REST API present in the module. The versions come centrally from the root `pom.xml` – so
add them **without** a `<version>`.

### 2. Enable the configuration

The engine stores its entire state in a relational database. In this training that's an **H2**
database that runs right inside the application and stores its data in a file under
`~/.operaton-training/`. There's nothing to install and nothing to start separately: H2 creates the
file on the first start, and the engine creates its `act_*` tables in it by itself.

In `services/process-application/src/main/resources/application.yaml`, uncomment the
`TODO Exercise 1` block. It contains:

- the database connection to the H2 file (`jdbc:h2:file:~/.operaton-training/exercise`, user
  `sa`, empty password),
- the **H2 console** – an SQL interface in the browser that is part of the application; you'll need
  it in step 5,
- the Cockpit admin user (`admin` / `admin`).

Without this block the application still starts – just not the way you need it: Spring Boot falls
back to a throwaway in-memory H2 on its own. The engine then creates no admin user, and instead of
the login the Cockpit redirects to the Admin app's **Operaton Setup** page, which asks you to create
an initial user. When started via `mvnw`, the H2 console is switched off (`/h2-console` returns
404), and all data is gone after a restart.

> **Term: embedded database.** A database that runs as a library **in the same process** as the
> application instead of as a separate server. It starts and stops with the application; because
> H2 writes to a file here, the data still survives a restart. Embedded doesn't mean in-memory: an
> in-memory database keeps everything in main memory only – like the fallback H2 when the block is
> missing, or the test database from Exercise 6 on.

### 3. Arm the application

In `TrainingApplication.java`, enable the commented-out annotations
**`@SpringBootApplication`** and **`@EnableJpaRepositories`**. Only then do auto-configuration
and the automatic BPMN deployment kick in: all `*.bpmn` files under `src/main/resources` are
deployed into the engine at startup.

### 4. Start the application

Now everything comes together. Watch the log – it shows how auto-configuration brings up the
engine and deploys the BPMN file.

```bash
cd services/process-application && ../../mvnw spring-boot:run
```

Look for this line in the log – it shows that the configuration from step 2 has taken effect and
the engine runs on the H2 file:

```
H2 console available at '/h2-console'. Database available at 'jdbc:h2:file:~/.operaton-training/exercise'
```

If it says `jdbc:h2:mem:…` instead of the file, or the line is missing entirely, the block from
step 2 isn't active.

### 5. Look at the engine's tables

On the first start the engine created its data model itself: several dozen tables with the prefix
`act_`. Look at them in the H2 console, which is built into the running application:

1. Open [http://localhost:8080/h2-console](http://localhost:8080/h2-console). Leave the setting
   **Generic H2 (Embedded)** as it is.
2. In the **JDBC URL** field, replace the pre-filled value `jdbc:h2:~/test` with
   `jdbc:h2:file:~/.operaton-training/exercise` – otherwise the console looks for a database that
   doesn't exist. After the first successful login the console remembers the URL.
3. Keep the user `sa`, leave the password empty, and click **Connect**.

The console now lists the tables in the left-hand column (H2 shows the table names in upper case;
in SQL the case doesn't matter). These five tables are the most important:

| Table | Prefix | Content |
|---|---|---|
| `act_re_procdef` | `re` = Repository | deployed **process definitions** (`subscribeNewsletter`) |
| `act_ru_execution` | `ru` = Runtime | **running** process instances |
| `act_ru_task` | `ru` | open **User Tasks** |
| `act_ru_variable` | `ru` | **process variables** of running instances |
| `act_hi_procinst` | `hi` = History | **completed** process instances |

As a start, check whether your model was deployed. Type the query into the console's input field
and click **Run**:

```sql
SELECT key_, name_, version_ FROM act_re_procdef;
```

On a fresh database the result is one row with `subscribeNewsletter`, `Join Inner Circle`, and
version `1`. More rows or higher versions mean another module has already run against the same
file – the process definitions of all modules accumulate there (see **Hints** for how to reset it).

### 6. Explore the Cockpit

The Cockpit is the engine's web interface. Open
[http://localhost:8080/operaton/app/cockpit/](http://localhost:8080/operaton/app/cockpit/)
(admin / admin). Under **Processes** you'll see `Join Inner Circle` – the display name of the
model; the technical process key behind it is `subscribeNewsletter`. Click your way through
**Cockpit**, **Tasklist**, and **Admin**.

### 7. Play through the process

The process is deployed, but has never run. Start it via the start form:

1. **Tasklist** → **Start process** → `Join Inner Circle`
2. A **start form** appears with the fields `email`, `name`, `age`. Fill it in and start.
3. The instance runs **without stopping** to the end – both Manual Tasks are simply run through
   by the engine.
4. Check the result in the H2 console with these three queries:

   ```sql
   SELECT proc_def_key_, state_ FROM act_hi_procinst;
   SELECT COUNT(*) FROM act_ru_execution;
   SELECT COUNT(*) FROM act_ru_task;
   ```

   The first shows your instance as `COMPLETED`, the other two return `0`: there are no running
   process instances and no open tasks any more.

> **Term: start form (Generated Form).** The fields `email`/`name`/`age` sit as `camunda:formData`
> directly on the Start Event. When you start, the Tasklist renders a form from them automatically –
> no extra file, no HTML. The entered values become process variables of the instance.

> **Term: Manual Task.** A task the engine does **not** execute and does **not** wait at – it
> simply runs through. A placeholder for "something happens here later". That's why the instance
> runs through the model in one go. From Exercise 2 on the first placeholder becomes a real User
> Task.

### 8. Optional: Connect EnterpriseGlue The Bridge

The Bridge is an additional web UI for the engine: you can model, deploy and manage processes
there – complementary to the Cockpit. None of the exercises depends on it – you can do everything
you need in the Cockpit. This step is the only one in the training that needs Docker: the Bridge
runs in Docker containers described by `stack/docker-compose.yml`. Bring them up in a second
terminal from the repository root – the application keeps running in the first one:

```bash
cd stack && docker-compose up -d
```

Then open the Bridge, log in, and connect it to your engine.

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
   From inside the container the host is reachable via `host.docker.internal` – not via `localhost`.
3. After **Create**, the engine shows the status **Connected**, and the same process definition
   (`Join Inner Circle` / `subscribeNewsletter`) shows up in the Bridge under **Mission Control**.

> **Term: EnterpriseGlue The Bridge.** An additional UI for the engine (model, deploy and
> manage BPMN/DMN). It speaks the same `engine-rest` API as the Cockpit, so it's an alternative to
> the classic Operaton web apps. The exact field labels may differ between Bridge versions; what
> matters is the engine's endpoint URL, a *direct* connection, and username/password.

> **Note: Why username/password?** The training engine runs without authentication and ignores the
> credentials. The Bridge, however, refuses to store an engine *without* credentials unless the engine
> sits behind a customer-managed gateway or sidecar (the other option under *How EnterpriseGlue
> connects*) and a platform admin has explicitly allowed that. `admin`/`admin` are the Cockpit admin
> credentials from `application.yaml` – so they'd also be right if you switched REST authentication on
> later.

## Constraints

- You work exclusively in the module `services/process-application`.
- The module already contains the complete skeleton of the hexagonal architecture. The business
  layer is commented out and isn't needed here yet.
- All modules run on port `8080` and use the same H2 file under `~/.operaton-training/`. Always
  start only one at a time – the running application locks the file.
- You only need Docker for the optional step 8 (Bridge); all other steps work without it.

## Expected result

The log shows the H2 line from step 4 with
`Database available at 'jdbc:h2:file:~/.operaton-training/exercise'`,
`Auto-Deploying resources: [... membership.bpmn]`, and `Started TrainingApplication`. The file
`exercise.mv.db` sits under `~/.operaton-training/`. The H2 console shows the `act_*` tables, the
Cockpit is reachable, `Join Inner Circle` appears under **Processes**, and an instance started via
the start form runs to the End Event without stopping.

## Self-check

- [ ] Dependencies, configuration, and `@SpringBootApplication` are enabled
- [ ] The application starts and deploys `membership.bpmn`
- [ ] The H2 console shows the `act_*` tables, and `act_re_procdef` contains `subscribeNewsletter`
- [ ] `Join Inner Circle` appears in the Cockpit under **Processes**
- [ ] An instance started via the start form runs all the way through (History `COMPLETED`)
- [ ] You can explain why the instance made up of nothing but Manual Tasks never waits
- [ ] Optional: the Bridge is reachable at `http://localhost:8081` and, once connected, shows the same process definition

## Hints

- If the Cockpit shows the **Operaton Setup** page for creating an initial user instead of the
  login, the block from step 2 is still commented out. The application then runs on a throwaway
  in-memory H2 without an admin user; the log shows `jdbc:h2:mem:…` instead of the H2 file. Don't
  create a user there – it would be gone after the next restart – but uncomment the block and start
  again. If you start the application from the IDE, `/h2-console` is reachable even without the
  block (Spring Boot DevTools switches the console on there); rely on the URL in the log.
- If startup fails with
  `Database may be already in use: "…/.operaton-training/exercise.mv.db"`, something else already
  has the file open – a different module, the same one in a second terminal, or a database tool
  such as *Database* in IntelliJ or *SQLTools* in VS Code. Stop the application or disconnect the
  tool and start again. Conversely, these tools can't open the file while the application is
  running – use the H2 console instead.
- If the H2 console reports
  `Database "…" not found, either pre-create it or allow remote database creation …`, the URL in
  the **JDBC URL** field is wrong – usually it still holds the pre-filled value `jdbc:h2:~/test`,
  sometimes it's a typo. Enter exactly `jdbc:h2:file:~/.operaton-training/exercise` as in step 5. If
  the message persists with the correct URL, the file doesn't exist yet: the application is running
  without the block from step 2.
- The engine's data survives a restart of the application. For a clean slate, stop the
  application and delete the folder `~/.operaton-training` (on Windows
  `%USERPROFILE%\.operaton-training`); on the next start, H2 and the engine create everything anew.
- The prefixes are a handy mnemonic: `re` is fixed, `ru` is moving, `hi` is the past.
- **Bridge (step 8):** If saving the engine in the Bridge fails with a generic error and
  `docker logs enterpriseglue-backend` shows
  `Engine base URL must use HTTPS when endpoint policy is enforced`, the Bridge backend is running
  without the `EG_ENGINE_*` variables from `stack/docker-compose.yml` (e.g. a container from an
  older compose file). Run `cd stack && docker-compose up -d` again so the backend is recreated. The
  sibling message `Engine base URL private host must have an exact endpoint-policy allowlist entry`
  means `localhost`/`127.0.0.1` was entered instead of `host.docker.internal`.
- **Bridge (step 8):** If `docker-compose up -d` stops with
  `container enterpriseglue-backend is unhealthy` and `docker logs enterpriseglue-backend` shows a
  failed migration (e.g. `column "user_id" does not exist`), the Bridge volumes stem from an older
  Bridge image. Either reset the Bridge volumes (fresh setup) or apply
  `stack/enterpriseglue-ledger-baseline-v0.19.2.sql` once – both recipes are in that file's header.

## Reference solution

- Finished module: `../../solutions/exercise-01/`
- Model: `../../models/exercise-01/membership.bpmn`
- Load it directly into the working module:

  ```bash
  ./mvnw -pl services/process-application antrun:run@load-solution -Dsolution=01
  ```

## Next step

In Exercise 2 the placeholder "Confirm" becomes a real **User Task**, which you model yourself
with a form.

➡️ [Next: Exercise 2](exercise-02.md)
