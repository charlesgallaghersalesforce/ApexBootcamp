trigger EmployeeAfterTrigger on Contact (after insert) 
{
    TriggerHandler handler = new TriggerHandler();
    handler.CreateActivityAssignments(Trigger.New);
}