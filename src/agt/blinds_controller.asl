// blinds controller agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds (was:Blinds)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/blinds.ttl").

// the agent initially believes that the blinds are "lowered"
blinds("lowered").

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Blinds is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", Url) <-
    .print("Hello world");
    // performs an action that creates a new artifact of type ThingArtifact, named "blinds" using the WoT TD located at Url
    makeArtifact("blinds", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId).


/* 
 * Plan for setting the blinds to a certain state
 * Triggering event: addition of goal !set_blinds_state
 * Context: true (the plan is always applicable)
 * Body: the agents raises or lowers the blinds.
*/
@set_blinds_state_plan
+!set_blinds_state(State): true <-
    .print("Set blinds to " , State);
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", [State]);
    -+blinds(State).

/* 
 * Plan for executing the task of a request for proposal
 * Triggering event: addition of goal !execute_task
 * Context: true (the plan is always applicable)
 * Body: the agents raises the blinds.
*/
@raise_blinds_plan
+!execute_task: true <-
    .print("Raise blinds to wake up user");
    !set_blinds_state("raised").

/* 
 * Plan for reacting to the addition of the belief !blinds
 * Triggering event: addition of belief !blinds
 * Context: true (the plan is always applicable)
 * Body: announces when the state of the blinds changes
*/
@blinds_state_plan
+blinds(State) : true <-
    .print("The blinds are ", State);
    .send(personal_assistant,tell,blinds_notification(State)).

/* 
 * Plan for reacting to the addition of the belief cfp
 * Triggering event: addition of belief cfp
 * Context: The blinds are lowered
 * Body: propose to raise the blinds
*/
@propose_plan
+cfp(CNPId)[source(A)]: blinds("lowered") <-
    -cfp(CNPId)[source(A)];
    .send(personal_assistant,tell,propose(CNPId));
    .print("Proposed to ", CNPId).

/* 
 * Plan for reacting to the addition of the belief cfp
 * Triggering event: addition of belief cfp
 * Context: The blinds are raised
 * Body: refuse the call
*/
@refuse_call_plan
+cfp(CNPId)[source(A)]: blinds("raised") <-
    -cfp(CNPId)[source(A)];
    .send(personal_assistant,tell,refuse(CNPId));
    .print("Refused call ", CNPId).

+accept_proposal(CNPId): true <- 
    .print("My proposal won ",CNPId,"!");
    -accept_proposal(CNPId);
    !execute_task.

+reject_proposal(CNPId): true <- 
    .print("My proposal lost ",CNPId,"!").

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }