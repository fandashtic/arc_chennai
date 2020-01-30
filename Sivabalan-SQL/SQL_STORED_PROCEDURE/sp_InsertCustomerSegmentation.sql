


CREATE Procedure sp_InsertCustomerSegmentation(
	@SegmentCode nvarchar(255),
	@Segment nvarchar(255),      
      @Description nvarchar(255),      
      @ParentID int)     
As    
	Insert Into CustomerSegment(SegmentCode, SegmentName, [Description], ParentID, ModifiedDate)      
			Values (@SegmentCode, @Segment, @Description, @ParentID, GetDate())
	Select @@Identity


