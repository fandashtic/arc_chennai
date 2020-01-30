CREATE procedure sp_acc_insertaccounts(@accountname nvarchar(255),@groupid integer,
@openingbalance decimal(18,6),@additionalfield1 decimal(18,6) =0,@additionalfield2 decimal(18,6) =0,
@additionalfield3 decimal(18,6) =0,@additionalfield4 datetime =NULL,@additionalfield5 datetime =NULL,
@additionalfield6 nvarchar(30)=N'',@additionalfield7 nvarchar(100)=N'',@additionalfield8 nvarchar(30)=N'',
@additionalfield9 nvarchar(30)=N'',@additionalfield10 nvarchar(30)=N'',@additionalfield11 nvarchar(30)=N'',
@additionalfield12 nvarchar(30)=N'',@additionalfield13 nvarchar(30)=N'',@additionalfield14 nvarchar(30)=N'',
@additionalfield15 datetime = NULL,@additionalfield16 datetime = NULL,@additionalfield17 datetime = NULL,
@additionalfield18 int = 0)
as
insert AccountsMaster([AccountName],[GroupID],[Active],[Fixed],[OpeningBalance],
[AdditionalField1],[AdditionalField2],[AdditionalField3],[AdditionalField4],
[AdditionalField5],[AdditionalField6],[AdditionalField7],[AdditionalField8],
[AdditionalField9],[AdditionalField10],[AdditionalField11],[AdditionalField12],
[AdditionalField13],[AdditionalField14],[CreationDate],[LastModifiedDate],[AdditionalField15],
[AdditionalField16],[AdditionalField17],[AdditionalField18])
values(@accountname,@groupid,1,0,@openingbalance,
@additionalfield1,@additionalfield2,@additionalfield3,@additionalfield4,@additionalfield5,
@additionalfield6,@additionalfield7,@additionalfield8,@additionalfield9,@additionalfield10,
@additionalfield11,@additionalfield12,@additionalfield13,@additionalfield14,getdate(),getdate(),
@additionalfield15,@additionalfield16,@additionalField17,@additionalfield18)
select @@identity 













