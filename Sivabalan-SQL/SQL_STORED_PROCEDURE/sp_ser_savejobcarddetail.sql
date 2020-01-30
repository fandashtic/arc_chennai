CREATE procedure [sp_ser_savejobcarddetail]  
 (@JobCardID  [int],  
  @Product_Code  [nvarchar](15),  
  @Product_Specification1  [nvarchar](50),  
  @Type  [int],  
  @JobID  [nvarchar](50),  
  @TaskID  [nvarchar](50),  
  @SpareCode  [nvarchar](15),  
  @Quantity  [decimal](18,6),  
  @UOM  [int],  
  @UOMQty  [decimal](18,6),  
  @DeliveryDate  [datetime],  
  @DeliveryTime  [datetime],  
  @JobType  [int],  
  @DoorDelivery  [int],  
  @InspectedBy  [nvarchar](50),  
  @CustomerComplaints  [text],  
  @TimeIn  [datetime],  
  @PersonnelComments  [text],  
  @Warranty    [int],  
  @WarrantyNo [nvarchar] (50),   
  @DateofSale [datetime], 
  @TaskType [int],
  @BounceJobCardID [int]=0)  
  
AS   
Declare @JobDetailSerialNo int   
Declare @FreeJob as int 
Select @FreeJob = [Free]from JobMaster where JobID = @JobID
Set @FreeJob = IsNUll(@FreeJob,0)

Set dateformat dmy  
INSERT INTO [dbo].[JobCardDetail]   
  ( [JobCardID],  
  [Product_Code],  
  [Product_Specification1],  
  [Type],  
  [JobID],  
  [TaskID],  
  [SpareCode],  
  [Quantity],  
  [UOM],  
  [UOMQty],  
  [DeliveryDate],  
  [DeliveryTime],  
  [JobType],  
  [DoorDelivery],  
  [InspectedBy],  
  [CustomerComplaints],  
  [TimeIn],  
  [PersonnelComments],  
  [Warranty],  
  [WarrantyNo],  
  [DateofSale], [TaskType], [JobFree], [JobCardID_Bounced])  
   
VALUES   
 ( @JobCardID,  
  @Product_Code,  
  @Product_Specification1,  
  @Type,  
  @JobID,  
  @TaskID,  
  @SpareCode,  
  @Quantity,  
  @UOM,  
  @UOMQty,  
  @DeliveryDate,  
  @DeliveryTime,  
  @JobType,  
  @DoorDelivery,  
  @InspectedBy,  
  @CustomerComplaints,  
  @TimeIn,  
  @PersonnelComments,  
  @Warranty,  
  @WarrantyNo,  
  @DateofSale, @TaskType, @FreeJob, @BounceJobCardID)  
  
Set @JobDetailSerialNo = @@Identity  
  
if @Type <> 0 and IsNull(@SpareCode,'') = ''    
 begin  
   Insert into JobCardTaskAllocation (JobCardID, Product_Code, Product_Specification1, 
   Type, JobID, TaskID, TaskStatus, LastUpdatedTime, TaskType, JobFree)   
   Values (@JobCardID, @Product_Code, @Product_Specification1, 
   @Type, @JobID, @TaskID, 0, getdate(), @TaskType, @FreeJob)  
 end  
  
if IsNull(@SpareCode , '') <> ''   
 begin  
   Insert into JobCardSpares (JobCardID, Product_Code, Product_Specification1, SpareCode,   
   UOM, Qty, Warranty, WarrantyNo, DateofSale, SpareStatus, PendingQty, JobID, TaskID, JobFree) 
   Values (@JobCardID, @Product_Code, @Product_Specification1, @SpareCode, 
   @UOM, @UOMQty, @Warranty, @WarrantyNo, @DateofSale, 0, @UOMQty, @JobID, @TaskID, @FreeJob)  
 end   
  
Select @JobDetailSerialNo ---- Jobcarddetail Serial Number  
  
/* 
JobID and TaskID Included in JobcardSpares
FreeJOB Included in Jobcard Spares JobCardTaskAllocation
Pending quantity stored in UOM Quantity (28.03.05)
18.05.05 Bounce case JobCardID Included To display the reason for Jobcard in reports
*/  




