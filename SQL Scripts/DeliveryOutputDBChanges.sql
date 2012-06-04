----*********** All Columns
ALTER TABLE [dbo].[Paid_API_AllColumns_v29]
DROP COLUMN [DeliveryFileName]

EXEC sp_rename 'Paid_API_AllColumns_v29.DeliveryID', 'DeliveryOutputID', 'column'

ALTER TABLE [dbo].[Paid_API_AllColumns_v29]
ALTER COLUMN [DeliveryOutputID] CHAR(32) null

----*********** Content
ALTER TABLE [dbo].Paid_API_Content_v29
DROP COLUMN [DeliveryFileName]

EXEC sp_rename 'Paid_API_Content_v29.DeliveryID', 'DeliveryOutputID', 'column'

ALTER TABLE [dbo].Paid_API_Content_v29
ALTER COLUMN [DeliveryOutputID] CHAR(32) null

----*********** BO
ALTER TABLE [dbo].BackOffice_Client_Gateway
DROP COLUMN [DeliveryFileName]

EXEC sp_rename 'BackOffice_Client_Gateway.DeliveryID', 'DeliveryOutputID', 'column'

ALTER TABLE [dbo].BackOffice_Client_Gateway
ALTER COLUMN [DeliveryOutputID] CHAR(32) null


