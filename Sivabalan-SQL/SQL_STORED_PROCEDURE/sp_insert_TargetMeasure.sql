
CREATE PROCEDURE [sp_insert_TargetMeasure]
	(@Description_2 	[nvarchar](128))

AS INSERT INTO [TargetMeasure] 
	 ([Description]) 
 
VALUES 
	(@Description_2)
select @@identity


