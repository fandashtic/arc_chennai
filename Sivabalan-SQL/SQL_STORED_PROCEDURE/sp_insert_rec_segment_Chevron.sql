CREATE Procedure sp_insert_rec_segment_Chevron            
(@segCode nVarchar(255),@segName  nvarchar(255),@Description  nvarchar(255),            
@parentCode nVarchar(255),@level int ,            
@ForumCode nVarchar(255),@Status Int)            
as            
Begin            
	set dateformat dmy            
	Declare @Cdt as DateTime            
	Declare @Mdt as DateTime            
	Declare @sID AS Int          
	Set @Cdt=Getdate()    
	Insert Into ReceivedSegments(SegmentCode,SegmentName,Description,ParentCode,Level,CreationDate,ModifiedDate,BranchForumCode,Status)            
	Values            
	(@segCode,@segName,@Description,@parentCode,@level,@Cdt,@Cdt,@ForumCode,@Status)            
	Select @@Identity           
End 
