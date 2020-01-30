Create procedure sp_update_PostDateInvoice(@PostDate  DateTime)  
As  
Update Setup Set Operating_Date = @PostDate  
  
