CREATE procedure sp_acc_getaccounts(@naccountid integer)
as
select accountname,accountid,accountsmaster.[active],1,[OpeningBalance],
[accountsmaster].[groupid],groupname,AdditionalField1,AdditionalField2,AdditionalField3,
AdditionalField4,AdditionalField5,AdditionalField6,AdditionalField7,AdditionalField8,
AdditionalField9,AdditionalField10,AdditionalField11,AdditionalField12,AdditionalField13,
AdditionalField14,'Fixed'=isnull([AccountsMaster].Fixed,0),[AdditionalField15],[AdditionalField16],
AdditionalField17,AdditionalField18,'DefaultGroupID'= IsNull(DefaultGroupID,0),
DefaultGroup = IsNull((Select GroupName from AccountGroup where GroupID = IsNull(DefaultGroupID,0)),0)
from accountsmaster,accountgroup where [accountid]=@naccountid 
and [accountsmaster].[groupid]=[accountgroup].[groupid]


