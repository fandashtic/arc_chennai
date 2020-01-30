
CREATE PROCEDURE sp_add_rejection_reason(@MESSAGE nvarchar(255))
as
INSERT INTO RejectionReason(Message) VALUES(@MESSAGE)
SELECT @@IDENTITY

