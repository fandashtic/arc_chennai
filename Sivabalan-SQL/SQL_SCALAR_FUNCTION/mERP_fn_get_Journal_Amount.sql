Create Function dbo.mERP_fn_get_Journal_Amount    
(@TransactionID int,@AccountID int,@Documentreference int,@Mode int)    
Returns decimal(18,4)    
AS    
BEGIN    
 /*Mode is used for knowing Dr. or Cr.*/    
 /*1 = Dr. 2 = Cr. */    
 Declare @Value decimal(18,4)    
 If (Select count(*) from generaljournal where transactionid=@TransactionID and Accountid=@AccountID) > 1      
 BEGIN    
  /* First check whether there is a old reference document available in the journal*/    
  If exists (Select isnull(Documentreference,0) from generaljournal where transactionid=@TransactionID and Accountid=@AccountID and Documentreference = 2)    
   if @mode = 1     
   BEGIN    
    /*If adjusted Document(s) value is equal to the value entered by the user then do the below step*/    
    if (select sum(debit)from generaljournal where transactionid=@TransactionID and Accountid=@AccountID and Documentreference <> 2) <>     
    (select debit from generaljournal where transactionid=@TransactionID and Accountid=@AccountID and Documentreference = 2)    
    BEGIN    
     /*If count of Document Reference = 2 is equal to <> 2 then do the below step*/    
     if (select count(*) from generaljournal where transactionid=@TransactionID and Accountid=@AccountID and Documentreference <> 2) =     
     (select count(*) from generaljournal where transactionid=@TransactionID and Accountid=@AccountID and Documentreference = 2)    
     BEGIN    
      select @Value = Debit from generaljournal where transactionid=@TransactionID and Accountid=@AccountID and Documentreference <> 2    
     END    
     ELSE    
     BEGIN    
      select @Value = Debit from generaljournal where transactionid=@TransactionID and Accountid=@AccountID and Documentreference <> 2    
      And Documentreference = @Documentreference     
     END    
    END    
    ELSE    
    BEGIN    
     select @Value = Debit from generaljournal where transactionid=@TransactionID and Accountid=@AccountID and Documentreference <> 2    
     And Documentreference = @Documentreference      
    END    
   END    
   ELSE    
   BEGIN    
    /*If adjusted Document(s) value is equal to the value entered by the user then do the below step*/    
    if (select sum(credit)from generaljournal where transactionid=@TransactionID and Accountid=@AccountID and Documentreference <> 2) <>     
    (select credit from generaljournal where transactionid=@TransactionID and Accountid=@AccountID and Documentreference = 2)    
    BEGIN    
     /*If count of Document Reference = 2 is equal to <> 2 then do the below step*/    
     if (select count(*) from generaljournal where transactionid=@TransactionID and Accountid=@AccountID and Documentreference <> 2) =     
     (select count(*) from generaljournal where transactionid=@TransactionID and Accountid=@AccountID and Documentreference = 2)    
     BEGIN    
      select @Value = Credit from generaljournal where transactionid=@TransactionID and Accountid=@AccountID and Documentreference <> 2    
     END    
     ELSE    
     BEGIN    
      select @Value = Credit from generaljournal where transactionid=@TransactionID and Accountid=@AccountID and Documentreference <> 2    
      And Documentreference = @Documentreference     
     END    
    END    
    ELSE    
    BEGIN    
     select @Value = Credit from generaljournal where transactionid=@TransactionID and Accountid=@AccountID and Documentreference <> 2    
     And Documentreference = @Documentreference      
    END    
   END    
 END    
 /* If there is NO old reference document available in the journal*/    
 ELSE    
 BEGIN    
  if @mode = 1     
  BEGIN    
   select @Value = Debit from generaljournal where transactionid=@TransactionID and Accountid=@AccountID and Documentreference <> 2    
  END    
  ELSE    
  BEGIN    
   select @Value = Credit from generaljournal where transactionid=@TransactionID and Accountid=@AccountID and Documentreference <> 2    
  END    
 END    
 Return isnull(@Value,0)    
END    
