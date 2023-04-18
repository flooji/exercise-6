// lights controller agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights (was:Lights)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/lights.ttl").

// The agent initially believes that the lights are "off"
lights("off").

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Lights is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", Url) <-
    .print("Hello world");
    // performs an action that creates a new artifact of type ThingArtifact, named "lights" using the WoT TD located at Url
    makeArtifact("lights", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId).

/* 
 * Plan for setting the lights to a certain state
 * Triggering event: addition of goal !set_lights_state
 * Context: true (the plan is always applicable)
 * Body: the agents turns the lights on or off.
*/
@set_lights_state_plan
+!set_lights_state(State): true <-
    .print("Set lights to " , State);
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", [State]);
    -+lights(State).

/* 
 * Plan for executing the task of a request for proposal
 * Triggering event: addition of goal !execute_task
 * Context: true (the plan is always applicable)
 * Body: the agents turns the lights on.
*/
@turn_lights_on_plan
+!execute_task: true <-
    .print("Turn lights on to wake up user");
    !set_lights_state("on").

/* 
 * Plan for reacting to the addition of the belief lights
 * Triggering event: addition of belief lights
 * Context: true (the plan is always applicable)
 * Body: announces when the state of the lights changes
*/
@lights_state_plan
+lights(State) : true <-
    .print("The lights are ", State);
    .send(personal_assistant,tell,lights_notification(State)).

/* 
 * Plan for reacting to the addition of the belief cfp
 * Triggering event: addition of belief cfp
 * Context: The lights are off
 * Body: propose to turn the lights on
*/
@propose_plan
+cfp(CNPId)[source(A)]: lights("off") <-
    -cfp(CNPId)[source(A)];
    .send(personal_assistant,tell,propose(CNPId));
    .print("Proposed to ", CNPId).


/* 
 * Plan for reacting to the addition of the belief cfp
 * Triggering event: addition of belief cfp
 * Context: The lights are on
 * Body: refuse the call
*/
@refuse_call_plan
+cfp(CNPId)[source(A)]: lights("on") <-
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