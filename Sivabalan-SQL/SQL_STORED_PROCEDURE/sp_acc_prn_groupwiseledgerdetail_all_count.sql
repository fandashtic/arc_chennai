CREATE procedure sp_acc_prn_groupwiseledgerdetail_all_count(@fromdate datetime,@todate datetime ,@parentid  integer, @DocRef integer,@doctype integer,@mode integer,@Info nvarchar(4000) = Null,@State Int=0,@Hide0BalAC Int =0)
as        
DECLARE @parentgroup1 integer,@groupid integer,@parentgroup  integer        
DECLARE @LEAFACCOUNT integer        
DECLARE @ACCOUNTGROUP integer        
DECLARE @NEXTLEVEL integer        
DECLARE @NONEXTLEVEL integer        
Declare @SPECIALCASE Integer      
        
SET @NEXTLEVEL =0        
SET @NONEXTLEVEL =1        
SET @LEAFACCOUNT =2        
SET @ACCOUNTGROUP =3        
SET @SPECIALCASE=4        
        
        
Declare @OpenDate DateTime -- Opening date from setup        
Select @OpenDate=dbo.stripdatefromtime(OpeningDate) from setup        
        
IF @mode = @ACCOUNTGROUP         
BEGIN        
	Create table #Groupids
	(
		Groupid integer
	)

 	set @parentgroup1 = @parentid        
	Insert into #Groupids select Groupid from Accountgroup where Groupid = @Parentid          

 	create Table #TempRegister(GroupID integer,GroupName nvarchar(50),Debit decimal(18,6),Credit decimal(18,6),FromDate datetime,ToDate datetime,DocRef integer,DocType integer,ColorInfo integer)        
         
	Declare Accountgroup cursor keyset for
	Select Groupid from #Groupids Where groupid <> 54

 	OPEN Accountgroup

	Fetch from Accountgroup into @Groupid
         
	While @@Fetch_status = 0
 	Begin
		Insert into #Groupids           
		Select GroupID From AccountGroup          
		Where ParentGroup = @GroupID --and isnull(Active,0)=1          
		Fetch Next From Accountgroup Into @GroupID          
	End

 	Close Accountgroup
	Deallocate Accountgroup

	Create table #AllGroupwiseledgerdetail
	(TransactionDate datetime,OriginalID nvarchar(15),Type nVarchar(255),
	AccountName nvarchar(50),AccountID int,FromDate datetime,ToDate datetime,
	DocRef int,DocType int,ColorInfoParam int,Particular nvarchar(255),
	Debit decimal(18,6),Credit decimal(18,6),Balance nvarchar(50),
	Document_Balance nvarchar(50),Narration nvarchar(2000),Cheque_Info nVarchar(255),
	HighLight int) 

	Declare @accountid Integer, @Accountname nVarchar(255)

	Declare AccountIds cursor keyset for
	Select accountid,Accountname from Accountsmaster where Groupid in 
	(Select Groupid from #Groupids)

	Open Accountids

	Fetch from AccountIds into @accountid, @Accountname

	While @@Fetch_Status = 0
	Begin
		If @Hide0BalAC = 1 
		Begin
			declare @BalanceExists decimal(18,6)
			exec sp_acc_closing_balance @fromdate,@todate,@accountid,@State,@BalanceExists output
			If @BalanceExists <> 0 
			Begin
				Insert into #AllGroupwiseledgerdetail(Type) Values(@Accountname)
				Insert into #AllGroupwiseledgerdetail(Type) Values('')
	
				Insert into #AllGroupwiseledgerdetail
				Exec sp_acc_rpt_account @fromdate,@todate,@accountid,@State  
				Insert into #AllGroupwiseledgerdetail(Type) Values('')
			End
		End
		Else
		Begin
			Insert into #AllGroupwiseledgerdetail(Type) Values(@Accountname)
			Insert into #AllGroupwiseledgerdetail(Type) Values('')
	
			Insert into #AllGroupwiseledgerdetail
			Exec sp_acc_rpt_account @fromdate,@todate,@accountid,@State  
			Insert into #AllGroupwiseledgerdetail(Type) Values('')
		End

		Fetch Next from AccountIds into @accountid, @Accountname
	End
	Close Accountids
	Deallocate Accountids

	select count(1) from #AllGroupwiseledgerdetail

 	Drop table #AllGroupwiseledgerdetail
	Drop table #Groupids
END        
ELSE IF @mode=@LEAFACCOUNT 
BEGIN      
	Create table #AllGroupwiseledgerdetailtemp
	(TransactionDate datetime,OriginalID nvarchar(15),Type nVarchar(255),
	AccountName nvarchar(50),AccountID int,FromDate datetime,ToDate datetime,
	DocRef int,DocType int,ColorInfoParam int,Particular nvarchar(255),
	Debit decimal(18,6),Credit decimal(18,6),Balance nvarchar(50),
	Document_Balance nvarchar(50),Narration nvarchar(2000),Cheque_Info nVarchar(255),
	HighLight int) 
	
  	Insert into #AllGroupwiseledgerdetailtemp
	exec sp_acc_rpt_account @fromdate,@todate,@parentid,@State  
	
	select count(1) from #AllGroupwiseledgerdetailtemp

	Drop table #AllGroupwiseledgerdetailtemp
END        
ELSE IF @mode =@NEXTLEVEL or @mode =@SPECIALCASE        
BEGIN        
   exec sp_acc_rpt_accountdetail @docref,@doctype,@Info         
END 




