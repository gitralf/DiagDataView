# DiagDataView
analyze diag data with powershell

showevents.ps1: needs powershell module for Get-DiagnosticData. Allows fine-granular analysis of (Windows) daignostic events from starttime to endtime.

analyze-ddv.ps1: No module required. Export (base) diagnostic events from Diagnostic Data Viewer to CSV and import into script: 

      analyze-ddv.ps1 -inputfile bla.csv
      
Todo:

  * check the main part of the events (currently only payload is checked)
  * include privTags in report
  * make table sortable by clicking on table header
  * map events to category even in DDV export (where does the category come from?)
  * include office events
    * is there a direct (powershell?) access to Office diagnostic data or only via DDV?  
    * Where to get a (json) file with Office diag events? Website only?
