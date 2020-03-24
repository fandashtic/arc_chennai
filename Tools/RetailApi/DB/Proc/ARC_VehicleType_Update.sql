--Exec ARC_VehicleType_Update 'SELF', 1
IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'ARC_VehicleType_Update')
BEGIN
	DROP PROC ARC_VehicleType_Update
END
GO
CREATE procedure [dbo].ARC_VehicleType_Update (@VehicleType NVARCHAR(255), @VehicleTypeId int = 0, @UserId int = 0)
As
Begin	
	IF NOT EXISTS(SELECT TOP 1 1 FROM VehicleType WITH (NOLOCK) WHERE (VehicleTypeId = @VehicleTypeId OR VehicleType = @VehicleType))
	BEGIN
		Insert Into VehicleType(VehicleType, CreatedBy)
		Select @VehicleType, @UserId
	END
	ELSE
	BEGIN
		Update P
		SET 
			P.VehicleType = @VehicleType,
			P.ModifiedBy = @UserId
		FROM VehicleType P WITH (NOLOCK) WHERE (VehicleTypeId = @VehicleTypeId OR VehicleType = @VehicleType)
	END	
END
GO

--SELECT * FROM VehicleType

Exec ARC_VehicleType_Update 'SELF', 1
Exec ARC_VehicleType_Update 'TN01AJ8915', 1
Exec ARC_VehicleType_Update 'TN05AU2342', 1
Exec ARC_VehicleType_Update 'TN12Q5058', 1
Exec ARC_VehicleType_Update 'TN22DC1397', 1
Exec ARC_VehicleType_Update 'TN58AR7296', 1
Exec ARC_VehicleType_Update 'TN66AB9203', 1
Exec ARC_VehicleType_Update 'TN66AB9208', 1
Exec ARC_VehicleType_Update 'TN66AB9219', 1
Exec ARC_VehicleType_Update 'TN66AB9220', 1
Exec ARC_VehicleType_Update 'TN66AB9235', 1
Exec ARC_VehicleType_Update 'TN66AB9256', 1
Exec ARC_VehicleType_Update 'TN66AB9265', 1
Exec ARC_VehicleType_Update 'TN66AB9277', 1
Exec ARC_VehicleType_Update 'TN66AB9280', 1
Exec ARC_VehicleType_Update 'TN66Y5494', 1
Exec ARC_VehicleType_Update 'TN99J5661', 1
GO