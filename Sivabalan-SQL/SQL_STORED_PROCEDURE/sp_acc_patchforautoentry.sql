CREATE Procedure sp_acc_patchforautoentry  
As  
Declare @FixedCount Int,@MAXCOUNT Int,@DiffAccount Int  
Set @MAXCOUNT=500  
Declare @FixedCount1 Int,@DiffAccount1 Int  
  
Select @FixedCount=Count(*) from AccountsMaster Where Fixed=1  
Set @DiffAccount=IsNull(@MAXCOUNT,0)-IsNull(@FixedCount,0)  
Select @FixedCount1=Count(*) from AccountGroup Where Fixed=1  
Set @DiffAccount1=IsNull(@MAXCOUNT,0)-IsNull(@FixedCount1,0)  
--AccountGroup  
Begin Tran  
If not Exists (Select GroupID From AccountGroup Where Fixed = 0 And GroupID < 500) Goto patch20  
CREATE TABLE [#TempAccountGroup] (  
 [GroupID] [int] NOT NULL ,  
 [GroupName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,  
 [AccountType] [int] NOT NULL ,  
 [ParentGroup] [int] NULL ,  
 [Active] [int] NOT NULL ,  
 [Fixed] [int] NULL ,  
 [CreationDate] [datetime] NULL ,  
 [LastModifiedDate] [datetime] NULL ,  
 [OrgType] [Int] NULL,
 CONSTRAINT [PK_AccountGroup] PRIMARY KEY  CLUSTERED   
 (  
  [GroupID]  
 )  ON [PRIMARY]   
) ON [PRIMARY]  
  
Insert #TempAccountGroup  
Select * from AccountGroup  
  
Update #TempAccountGroup Set GroupID=IsNull(GroupID,0)+@DiffAccount1 Where GroupID>IsNull(@FixedCount1 ,0)  
Insert Into #TempAccountGroup(GroupID,GroupName,AccountType,ParentGroup,Fixed,Active) Values (500,'User AccountGroup Start',0,0,0,0)  
  
Truncate Table AccountGroup  
SET IDENTITY_INSERT AccountGroup ON  
Insert Into AccountGroup  
( [GroupID],  
 [GroupName],  
 [AccountType],  
 [ParentGroup],  
 [Active],  
 [Fixed],  
 [CreationDate],  
 [LastModifiedDate],
 [OrgType]  
)  
Select * from #TempAccountGroup order by GroupID  
SET IDENTITY_INSERT AccountGroup OFF  
Drop Table #TempAccountGroup  
--Group Updation in Accountsmaster and AccountGroup  
Update AccountGroup Set ParentGroup=IsNull(ParentGroup,0)+@DiffAccount1 Where ParentGroup>IsNull(@FixedCount1 ,0)  
Update AccountsMaster Set GroupID=IsNull(GroupID,0)+@DiffAccount1 Where GroupID>IsNull(@FixedCount1 ,0)  
  
patch20:  
--AccountsMaster  
If not Exists (Select AccountID From AccountsMaster Where Fixed = 0 And AccountID < 500) Goto patch30  
CREATE TABLE [#TempAccountsMaster] (  
 [AccountID] [int] Not NULL ,  
 [AccountName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,  
 [GroupID] [int] NOT NULL ,  
 [Active] [int] NOT NULL ,  
 [Fixed] [int] NOT NULL ,  
 [OpeningBalance] [float] NULL ,  
 [AdditionalField1] [float] NULL ,  
 [AdditionalField2] [float] NULL ,  
 [AdditionalField3] [float] NULL ,  
 [AdditionalField4] [datetime] NULL ,  
 [AdditionalField5] [datetime] NULL ,  
 [AdditionalField6] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,  
 [AdditionalField7] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,  
 [AdditionalField8] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,  
 [AdditionalField9] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,  
 [AdditionalField10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,  
 [AdditionalField11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,  
 [AdditionalField12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,  
 [AdditionalField13] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,  
 [AdditionalField14] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,  
 [CreationDate] [datetime] NULL ,  
 [LastModifiedDate] [datetime] NULL ,  
 [AdditionalField15] [datetime] NULL ,  
 [AdditionalField16] [datetime] NULL ,  
 [AdditionalField17] [datetime] NULL ,  
 [UserName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,  
 [RetailPaymentMode] [int] NULL ,  
 [AdditionalField18] [int] NULL ,  
 [OrgType] [int] NULL ,  
 CONSTRAINT [PK_AccountsMaster] PRIMARY KEY  CLUSTERED   
 (  
  [AccountID]  
 )  ON [PRIMARY]   
) ON [PRIMARY]  
  
Insert #TempAccountsMaster  
Select * from AccountsMaster  
  
Update #TempAccountsMaster Set AccountID=IsNull(AccountID,0)+@DiffAccount Where AccountID>IsNull(@FixedCount ,0)  
Insert Into #TempAccountsMaster(AccountID,AccountName,GroupID,Fixed,Active) Values (500,'User Account Start',0,0,0)  
  
Truncate Table AccountsMaster  
SET IDENTITY_INSERT AccountsMaster ON  
Insert Into AccountsMaster  
( [AccountID],  
 [AccountName],  
 [GroupID],  
 [Active],  
 [Fixed],  
 [OpeningBalance],  
 [AdditionalField1],  
 [AdditionalField2],  
 [AdditionalField3] ,  
 [AdditionalField4],  
 [AdditionalField5],  
 [AdditionalField6],  
 [AdditionalField7],  
 [AdditionalField8],  
 [AdditionalField9],  
 [AdditionalField10],  
 [AdditionalField11],  
 [AdditionalField12],  
 [AdditionalField13],  
 [AdditionalField14],  
 [CreationDate],  
 [LastModifiedDate],  
 [AdditionalField15],  
 [AdditionalField16],  
 [AdditionalField17],  
 [UserName],  
 [RetailPaymentMode],  
 [AdditionalField18],  
 [OrgType]  
)  
Select * from #TempAccountsMaster order by AccountID  
SET IDENTITY_INSERT AccountsMaster OFF  
Drop Table #TempAccountsMaster  
  
--ARV  
Update ARVAbstract Set PartyAccountID=IsNull(PartyAccountID,0)+@DiffAccount Where PartyAccountID>IsNull(@FixedCount ,0)  
Update ARVAbstract Set ApprovedBy=IsNull(ApprovedBy,0)+@DiffAccount Where ApprovedBy>IsNull(@FixedCount ,0)  
Update ARVDetail Set AccountID=IsNull(AccountID,0)+@DiffAccount Where AccountID>IsNull(@FixedCount ,0)  
  
--APV  
Update APVAbstract Set PartyAccountID=IsNull(PartyAccountID,0)+@DiffAccount Where PartyAccountID>IsNull(@FixedCount ,0)  
Update APVAbstract Set ApprovedBy=IsNull(ApprovedBy,0)+@DiffAccount Where ApprovedBy>IsNull(@FixedCount ,0)  
Update APVAbstract Set OtherAccountID=IsNull(OtherAccountID,0)+@DiffAccount Where OtherAccountID>IsNull(@FixedCount ,0)  
Update APVAbstract Set ExpenseFor=IsNull(ExpenseFor,0)+@DiffAccount Where ExpenseFor>IsNull(@FixedCount ,0)  
Update APVDetail Set AccountID=IsNull(AccountID,0)+@DiffAccount Where AccountID>IsNull(@FixedCount ,0)  
  
--Bank  
Update Bank Set AccountID=IsNull(AccountID,0)+@DiffAccount Where AccountID>IsNull(@FixedCount ,0)  
  
--Batch_Assets  
Update Batch_Assets Set AccountID=IsNull(AccountID,0)+@DiffAccount Where AccountID>IsNull(@FixedCount ,0)  
Update Batch_Assets Set SupplierID=IsNull(SupplierID,0)+@DiffAccount Where SupplierID>IsNull(@FixedCount ,0)  
  
--Collections  
Update Collections Set Others=IsNull(Others,0)+@DiffAccount Where Others>IsNull(@FixedCount ,0)  
Update Collections Set ExpenseAccount=IsNull(ExpenseAccount,0)+@DiffAccount Where ExpenseAccount>IsNull(@FixedCount ,0)  
  
--Payments  
Update Payments Set Others=IsNull(Others,0)+@DiffAccount Where Others>IsNull(@FixedCount ,0)  
Update Payments Set ExpenseAccount=IsNull(ExpenseAccount,0)+@DiffAccount Where ExpenseAccount>IsNull(@FixedCount ,0)  
  
--CreditNote  
Update CreditNote Set AccountID=IsNull(AccountID,0)+@DiffAccount Where AccountID>IsNull(@FixedCount ,0)  
Update CreditNote Set Others=IsNull(Others,0)+@DiffAccount Where Others>IsNull(@FixedCount ,0)  
  
--Customer  
Update Customer Set AccountID=IsNull(AccountID,0)+@DiffAccount Where AccountID>IsNull(@FixedCount ,0)  
  
--DebitNote  
Update DebitNote Set AccountID=IsNull(AccountID,0)+@DiffAccount Where AccountID>IsNull(@FixedCount ,0)  
Update DebitNote Set Others=IsNull(Others,0)+@DiffAccount Where Others>IsNull(@FixedCount ,0)  
  
--Deposits  
Update Deposits Set AccountID=IsNull(AccountID,0)+@DiffAccount Where AccountID>IsNull(@FixedCount ,0)  
Update Deposits Set StaffID=IsNull(StaffID,0)+@DiffAccount Where StaffID>IsNull(@FixedCount ,0)  
Update Deposits Set ToAccountID=IsNull(ToAccountID,0)+@DiffAccount Where ToAccountID>IsNull(@FixedCount ,0)  
  
--GeneralJournal  
Update GeneralJournal Set AccountID=IsNull(AccountID,0)+@DiffAccount Where AccountID>IsNull(@FixedCount ,0)  
  
--Vendors  
Update Vendors Set AccountID=IsNull(AccountID,0)+@DiffAccount Where AccountID>IsNull(@FixedCount ,0)  
  
--WareHouse  
Update WareHouse Set AccountID=IsNull(AccountID,0)+@DiffAccount Where AccountID>IsNull(@FixedCount ,0)  
  
--AccountOpeningBalance  
Update AccountOpeningBalance Set AccountID=IsNull(AccountID,0)+@DiffAccount Where AccountID>IsNull(@FixedCount ,0)  
Patch30:  
Commit Tran    



