// calendar manager agent

/* Initial beliefs */
upcoming_event(_).

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService (was:CalendarService)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/calendar-service.ttl").

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:CalendarService is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService", Url) <-
    .print("Hello world");
        // performs an action that creates a new artifact of type ThingArtifact, named "calendar" using the WoT TD located at Url
    // the action unifies ArtId with the ID of the artifact in the workspace
    makeArtifact("calendar", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId);
    !read_upcoming_event. // creates the goal !read_upcoming_event

/* 
 * Plan for reacting to the addition of the goal !read_upcoming_event
 * Triggering event: addition of goal !read_upcoming_event
 * Context: true (the plan is always applicable)
 * Body: every 5000ms, the agent exploits the TD Property Affordance of type was:ReadUpcomingEvent
 *       and updates its belief upcoming_event accordingly
*/
@read_upcoming_event_plan
+!read_upcoming_event : true <-
    // performs an action that exploits the TD Property Affordance of type was:ReadUpcomingEvent 
    readProperty("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#ReadUpcomingEvent",  UpcomingEventStateLst);
    .nth(0,UpcomingEventStateLst,UpcomingEventState); // performs an action that unifies UpcomingEventState with the element of the list UpcomingEventState at index 0
    -+upcoming_event(UpcomingEventState); // updates the beleif upcoming_event 
    .wait(5000);
    !read_upcoming_event. // creates the goal !read_upcoming_event


/* 
 * Plan for reacting to the addition of the belief !upcoming_event
 * Triggering event: addition of belief !upcoming_event
 * Context: true (the plan is always applicable)
 * Body: announces when the state of an upcoming event changes
*/
@upcoming_event_state_plan
+upcoming_event(State) : true <-
    .print("There is an upcoming event ", State);
    .send(personal_assistant,tell,upcoming_event_notification(State)).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }
