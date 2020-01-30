CREATE Procedure sp_CheckDuplicate_SegmentName(@segName nVarchar(255)='',@segCode nVarchar(255)='')  
As  
Begin  
	if @segCode=''  
	Begin  
		if (Select Count(*) From CustomerSegment Where SegmentName=@SegName) > 0   
			Select 1  
		else  
			Select 0  
	End  
	Else  
	Begin  
		if (Select Count(*) From CustomerSegment Where SegmentName=@segName And SegmentCode <>@segCode) > 0   
			Select 1  
 		else  
			Select 0  
	End    
End    
  
