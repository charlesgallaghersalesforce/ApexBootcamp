trigger EmployeeAfterTrigger on Contact (after insert) 
{
    EmployeeTriggerHandler handler = new EmployeeTriggerHandler();
    handler.CreateActivityAssignments(Trigger.New);
}