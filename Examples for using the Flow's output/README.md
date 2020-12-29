3 examples:
  1) Power BI. Power query is able to consume Flow's HTTP trigger/response perfectly. Make sure parallel loading is switched off and implement table.buffer.
  2) Another Flow, for scheduling or integration with other processes.
  3) Powershell, for scripted solutions or testing.

If you want to retrieve everything, use 'all' as the value for modifiedSince. When using a real modifiedSince, keep in mind that you can only go back 30 days.
