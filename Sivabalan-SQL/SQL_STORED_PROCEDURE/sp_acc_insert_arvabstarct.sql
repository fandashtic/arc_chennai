


CREATE procedure sp_acc_insert_arvabstarct(@ARVDate datetime,
					   @PArtyAccountID Int,
					   @Value float,
					   @ARVemarks nvarchar(4000),
					   @ApprovedBy integer)


as
Declare @DocID nvarchar(50)
Begin Tran
select @DocID = DocumentID from DocumentNumbers where Doctype = 54
update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 54
Commit Tran

insert into ARVAbstract(ARVID,
			ARVDate,
			PartyAccountID,
			Amount,
			ARVRemarks,
			ApprovedBy)

values
		       (@DocID,
			@ARVDate,
			@PartyAccountID,
			@Value,
			@ARVemarks,
			@ApprovedBy)


select @@IDENTITY, @DocID











