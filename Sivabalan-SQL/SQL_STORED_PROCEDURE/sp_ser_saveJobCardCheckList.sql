CREATE PROCEDURE [sp_ser_saveJobCardCheckList]
	(@SerialNo int, 
	 @CheckListID [nvarchar](50),
	 @CheckListItemID [nvarchar](50),
	 @FieldType [int],
	 @FieldValue [nvarchar](255))

AS INSERT INTO [JobCardCheckList] 
	 ( [SerialNo],
	 [CheckListID],
	 [CheckListItemID],
	 [FieldType],
	 [FieldValue]) 
 
VALUES 
	(@SerialNo,
	 @CheckListID,
	 @CheckListItemID,
	 @FieldType,
	 @FieldValue)

