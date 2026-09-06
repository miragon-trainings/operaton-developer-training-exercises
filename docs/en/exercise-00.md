# Exercise 0 – Model the target process at the business level

> **Prerequisite:** Chapter 1 – you know BPMN as a notation: events, tasks, sequence flow, gateways. Subprocess, boundary events and compensation you apply here for the first time at the business level (deepened technically in later exercises).
> **Working directory:** any folder you like (no code yet, no module yet).
> **New in this exercise:** BPMN modeler, the complete target process as a shared map.

## What this is about

**Miravelo** is an online shop for premium bikes – gravel bikes for long weekend
tours, road bikes for everyone who likes to move fast on the asphalt. The customers
are young, brand-conscious and pretty passionate.

Miravelo turns this into more than a mailing list: the **Inner Circle**, an exclusive
membership with a limited number of seats. Whoever wants to join registers, confirms via
double opt-in, gets a seat reserved – and is welcomed in the end. Sounds like four boxes,
but it has confirmation deadlines, a capacity limit and a fallback for when there is no
free seat after all.

> *"Let's sketch this out before anyone starts coding."*
> — the one sensible sentence in the whole kickoff.

Before anything gets automated, you capture the **complete target process at the business
level**: what happens, in what order, where does the process wait, where does it branch?
This is the language in which the business side and development reach agreement – without a
single line of technology. This model is the **map for the entire training**: from Exercise 1
on you automate it piece by piece.

## Learning goals

After this exercise you can

- install a BPMN modeler and create an end-to-end model in it,
- apply the notation from Chapter 1 to a real business process – Start and End Events,
  User Task and Service Task, Exclusive and Parallel Gateway – and put the advanced forms
  embedded subprocess, boundary events and compensation to use here for the first time at the
  business level,
- justify the waiting and branching points in the flow (where does the process wait for a
  human, where for a deadline, where does a condition decide),
- name elements so the business side can read the flow out loud without follow-up questions.

## Target model

This is the complete target process of the Inner Circle. It looks big – but it is only the
sum of many small building blocks you already know. This is exactly the flow you rebuild
technically, step by step, over the course of the training.

![BPMN model for the exercise](../assets/exercise-00.svg)

## The task

### 1. Install the modeler in your IDE

We model straight inside the IDE – no separate app needed. Install the **Miragon BPMN Modeler**
as a [VS Code extension](https://marketplace.visualstudio.com/items?itemName=miragon-gmbh.vs-code-bpmn-modeler)
or as an [IntelliJ plugin](https://plugins.jetbrains.com/plugin/32634-miragon-bpmn-modeler).
Whichever IDE you pick, it is the same modeler – so every following exercise opens the model in a
real modeler. Without VS Code or IntelliJ, use the
[standalone desktop app](https://miragon.github.io/bpmn-modeler/) as a fallback. Then create a new
BPMN diagram.

### 2. Model registration and capacity check

Start with the backbone of the process: a prospect registers, the process reserves a seat
and then checks whether one is free at all. If none is free, the application ends with a
rejection.

| Type | Name |
|---|---|
| Start Event | Submit registration form |
| Service Task | Claim membership |
| Exclusive Gateway | Free seat available? |
| Service Task | Send rejection mail |
| End Event | Membership rejected |

Connect Start → *Claim membership* → *Free seat available?*. From the gateway a **No** path leads
to *Send rejection mail* → *Membership rejected*. The **Yes** path stays open for now – you
fill it in the next step. The seat is reserved **before** the check; step 6 deals with that.

### 3. Model the confirmation as a subprocess

Whoever gets a seat has to actively confirm the membership (double opt-in). Bundle this
confirmation flow into an **embedded subprocess** – it will soon get its own deadlines and
exceptions, and a subprocess keeps that tidy.

Model the subprocess **Confirm membership** and inside it:

| Type | Name |
|---|---|
| Start Event (inside the subprocess) | Confirmation required |
| Service Task | Send confirmation mail |
| User Task | Confirm membership |
| End Event (inside the subprocess) | Membership confirmed |

Route the **Yes** path of the gateway from step 2 into this subprocess. At the *User Task* the
process stops: here it waits until a human confirms.

### 4. Add reminder, deadline and rejection

People don't always confirm right away – some never do. So attach **boundary events** to the
subprocess *Confirm membership* that model three exceptions:

| Boundary event | Type | Name | Leads to |
|---|---|---|---|
| Reminder | Timer, non-interrupting, daily | Every day | Service Task *Re-Send confirmation mail* → End Event *Mail sent again* |
| Abort after deadline | Timer, interrupting, 3½ days | After 3 1/2 days | End Event *Membership declined* |
| Active rejection | Message, interrupting | Confirmation rejected | End Event *Membership declined* |

The **non-interrupting** timer event lets the subprocess keep running and sends a daily
reminder on the side. The two **interrupting** events abort the confirmation and lead to
*Membership declined*.

### 5. Model the activation in parallel

Once the membership is confirmed, the member is activated – and two things happen at once:
the welcome mail goes out, and the community is notified. Model this with a **Parallel Gateway**
(fork and join). Close the fork with a parallel join of the same type (AND with AND), so both
branches are synchronised again before you reach *Membership activated*.

| Type | Name |
|---|---|
| Parallel Gateway (fork) | – |
| Service Task | Send Welcome Mail |
| Service Task | Notify community |
| Parallel Gateway (join) | – |
| End Event | Membership activated |

Route the exit of the subprocess into the fork, both service tasks in parallel, then into the
join and to *Membership activated*.

### 6. Add compensation

A reserved seat must not go to waste if the application fails in the end. When the membership
is declined (*Membership declined*), the reservation from step 2 has to be **undone**. That is
exactly what compensation is for.

- Attach a **Compensation Boundary Event** named *Membership declined* to *Claim membership*.
- Create a compensation handler *Revoke claim* (Service Task) and connect it to the boundary
  event via an **association**. It sits **outside** the normal sequence flow.
- Turn the End Event *Membership declined* into a **Compensating End Event** – it triggers the
  compensation.

### 7. Save the model

Save the file as `membership.bpmn` in a folder of your choice. It is your reference picture for
all the exercises that follow.

## Constraints

- **Business level only.** This is about flow and naming. Element IDs by convention, form
  fields, wiring service tasks to Java code as well as `isExecutable` and `historyTimeToLive`
  are deliberately left out here – that comes from Exercise 2 on.
- **Model it clean, not just complete.** Apply the modelling rules from Chapter 1: name every
  activity as a verb plus object (*Claim membership*), every gateway as a question and every
  outgoing sequence flow as the answer (*Yes* / *No*). Frame the flow with Start and End Events and
  give each End Event its own name. Keep the happy path – registration, confirmation, activation –
  on a straight line from left to right, and route the exceptions (rejection, deadline, decline,
  reminder) away above or below without crossing flows. Branch only at gateways: fork and join are
  separate diamonds.
- **This is the target state, not the first step.** Nobody automates this process in one go.
  From Exercise 1 on you take on small excerpts.
- **Don't copy it into the module yet.** Under `services/process-application/src/main/resources/bpmn/`
  there is already a deliberately rudimentary `membership.bpmn` that you need in Exercise 1.
  Don't overwrite it now.
- Model names are English throughout; the task descriptions are available in German and English.

## Expected result

Your model captures the complete flow: registration, seat reservation, the capacity gateway,
the confirmation subprocess with reminder, deadline and rejection, the parallel activation and
the compensation of the reservation. The modeler reports no errors, and someone from the
business side could read the flow out loud without asking what a single element means.

## Self-check

- [ ] The process is framed with Start and End Events: the main flow starts at *Submit
      registration form*, the confirmation subprocess has its own start, and every End Event carries
      its own name (*Membership activated*, *Membership rejected*, *Membership declined*, *Mail sent
      again*, plus *Membership confirmed* inside the subprocess)
- [ ] Every activity is named as a verb plus object, the Exclusive Gateway as a question
      (*Free seat available?*) and its outgoing sequence flows as the answer (*Yes* / *No*)
- [ ] Capacity is checked via an Exclusive Gateway with a **No** path to the rejection
- [ ] The confirmation lives in an embedded subprocess with a User Task
- [ ] Three boundary events hang on the subprocess: a daily (non-interrupting) timer, a 3½-day
      timer (interrupting) and a message event (interrupting)
- [ ] The activation runs through a Parallel Gateway; the fork is closed with a parallel join of
      the same type that waits for both branches (welcome mail and community notification run at the
      same time)
- [ ] *Revoke claim* is a compensation handler, attached via an association to the boundary
      event of *Claim membership*, and *Membership declined* is a Compensating End Event
- [ ] The happy path runs straight from left to right; exception paths branch away without crossing
      flows, and no gateway merges and splits at once (fork and join are separate diamonds)
- [ ] You walked every path once by hand: happy path, rejection, deadline abort, active rejection
      and the daily reminder each end in exactly one named End Event; no branch runs into nothing
- [ ] You can say in one sentence each where the flow waits for a human (at the User Task) and why
      the Exclusive Gateway branches
- [ ] All elements are connected via sequence flows – no dangling element
- [ ] The file is saved as `membership.bpmn`

## Hints

Don't let the size scare you: every advanced building block gets its **own exercise** later, in
which you implement it technically – the confirmation step in Exercise 4, the capacity gateway
in Exercise 5, subprocess and boundary events in Exercise 7, compensation in Exercise 8. Here you
first draw the whole map, so that at every partial step you know where it belongs.

Why a User Task and a Service Task? The **User Task** waits for a human – someone confirms the
membership. The **Service Task** is handled by a system – the mail dispatch, the seat
reservation. This distinction defines where the process waits and where it continues on its own.
By the way, the three mails are **Service Tasks**, not Send Tasks – a system handles them (from
Exercise 3 on you implement them as a JavaDelegate). Manual Task, Business Rule Task, Script Task
and the remaining task types from Chapter 1 only appear later or stay out entirely.

**Why no pools, lanes or data objects?** The whole flow runs inside Miravelo, with a single human
touchpoint – the User Task *Confirm membership*; every other step is a Service Task. Following the
'lanes with discipline' rule a System gets no lane of its own, and a single participant needs
neither a Pool nor a Lane – both would only fill this map with noise. Data objects are purely
descriptive; the engine does not evaluate them, so we deliberately leave them out here and focus on
flow and naming.

## Reference solution

`../../models/exercise-00/membership.bpmn` – open the model in the modeler and compare it with
yours.

## Next step

In Exercise 1 you get the engine running that executes exactly these kinds of models – starting
with a deliberately tiny excerpt.

➡️ [Next: Exercise 1](exercise-01.md)
