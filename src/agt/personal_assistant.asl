// personal assistant agent

/* Initial beliefs */
upcoming_event(_).
owner_state(_).
// The agent believes that the preferred wakeup method is...
artificial_light(1).
natural_light(0).

/* Initial rules */
// Inference rule for infering the belief best_option depending on which wakeup method is the prefered one
is_best_option_natural_light:- artificial_light(A) & natural_light(N) & (N < A).
is_best_option_artificial_light:- artificial_light(A) & natural_light(N) & (A < N).

no_options_left:- artificial_light(A) & natural_light(N) & N == A.

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: true (the plan is always applicable)
 * Body: greets the user
*/
@start_plan
+!start : true <-
    .print("Hello world");
    makeArtifact("dweet","room.DweetArtifact",[], DweetId);
    focus(DweetId);
    .print("Created dweet artifact ", DweetId);
    !dweet("Hello world");
    !assist_user.

/* 
 * Plan for reacting to the addition of the goal !create_and_observe_dweet_artifact_plan
 * Triggering event: addition of goal !create_and_observe_dweet_artifact_plan
 * Context: true (the plan is always applicable)
 * Body: create and focus on dweet artifact
*/
@dweet_plan
+!dweet(Message): true <-
    sendMessage("Fred", Message);
    .print("Sent message: ", Message).

/* 
 * Plan for reacting to the addition of the goal !react_to_events
 * Triggering event: addition of goal !react_to_events
 * Context: always true
 * Body: the agent assists the user by reacting to user & environment events
*/
@assist_user_plan
+!assist_user: true <-
    .print("Assist user");
    .wait(3000);
    !react_to_events;
    !assist_user.

/* 
 * Plan for reacting to the addition of the goal !react_to_events
 * Triggering event: addition of goal !react_to_events
 * Context: the agent believes that the upcoming_event is "now" & the owner is "asleep"
 * Body: the agent starts the wake up routine
*/
@wakeup_user_failed_plan
+!react_to_events: upcoming_event("now") & owner_state("asleep") & refuse("CFP_WAKE_UP_USER_1")[source(blinds_controller),source(lights_controller)] <-
    !wakeup_by_friend.


@wakeup_by_friend_plan
+!wakeup_by_friend: true <-
    !dweet("Your friend needs to be waken up. Please help!").

/* 
 * Plan for reacting to the addition of the goal !assist_user
 * Triggering event: addition of goal !assist_user
 * Context: the agent believes that the upcoming_event is "now" & the owner is "asleep"
 * Body: the agent starts the wake up routine
*/
@wakeup_user_plan
+!react_to_events: upcoming_event("now") & owner_state("asleep") <-
    .print("Starting wake-up routine. Call for wakeup proposals...");
    .broadcast(tell, cfp("CFP_WAKE_UP_USER_1")).
    

/* 
 * Plan for reacting to the addition of the goal !assist_user
 * Triggering event: addition of goal !assist_user
 * Context: the agent believes that the upcoming_event is "now" and that the owner is "awake"
 * Body: the agent greets the owner
*/
@greet_user_plan
+!react_to_events: upcoming_event("now") & owner_state("awake") <-
    .print("Enjoy your event").
    
/* 
 * Plan for reacting to the addition of the goal !react_to_proposal
 * Triggering event: addition of goal !react_to_proposal
 * Context: the agent believes that the calling agent is lights_controller and that artificial light is the best wake up option
 *          or the calling agent is blinds_controller and that natural light is the best wake up option
 * Body: the agent's proposal gets accepted
*/
@accept_proposal_plan
+!react_to_proposal(CNPId, A): (A == lights_controller & is_best_option_artificial_light) | (A == blinds_controller & is_best_option_natural_light)   <-
    .print("React to proposal from ", A);
    .send(A,tell,accept_proposal(CNPId));
    !update_best_wakeup_method.

/* 
 * Plan for reacting to the addition of the goal !update_best_wakeup_method
 * Triggering event: addition of goal !update_best_wakeup_method
 * Context: the agent believes that the best current option is artificial light
 * Body: artificial light is set to be no longer the best option
*/
@remove_artificial_light_as_best_option_plan
+!update_best_wakeup_method: is_best_option_artificial_light  <-
    -+artificial_light(2). // remove and add the new belief, we put it to a value higher than 0 or 1

/* 
 * Plan for reacting to the addition of the goal !update_best_wakeup_method
 * Triggering event: addition of goal !update_best_wakeup_method
 * Context: the agent believes that the best current option is natural light
 * Body: natural light is set to be no longer the best option
*/
@remove_natural_light_as_best_option_plan
+!update_best_wakeup_method: is_best_option_natural_light  <-
    -+natural_light(2). // remove and add the new belief, we put it to a value higher than 0 or 1

/* 
 * Plan for reacting to the addition of the goal !react_to_proposal
 * Triggering event: addition of goal !react_to_proposal
 * Context: always true
 * Body: reject agent's proposal
*/
@reject_proposal_plan
+!react_to_proposal(CNPId, A): true <-
    .send(A,tell,reject_proposal(CNPId)).

+dweet(Tweet): true <-
    .print("Received new tweet: ", Tweet).


+lights_notification(State): true <-
    .print("Received message about light change to ", State).

+blinds_notification(State): true <-
    .print("Received message about blinds change to ", State).

+upcoming_event_notification(State): true <-
    .print("Received message about upcoming event change to ", State);
    -+upcoming_event(State).

+owner_state_notification(State): true <-
    .print("Received message about owner state change to ", State);
    -+owner_state(State).

+propose(CNPId)[source(A)]: true <-
    .print("Agent ", A, " proposed to cfp ", CNPId);
    !react_to_proposal(CNPId, A);
    -propose(CNPId)[source(A)].


+refuse(CNPId)[source(A)]: true <-
   .print("Agent ", A, " refused to ", CNPId).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }