CREATE VIEW dbo.view_invoice
AS
SELECT     TOP 100 PERCENT dbo.jinvoice.JIHdr_JInvoice_UID AS HdrUID, dbo.jinvoice.JIHdr_DateInv_DT AS DateInvoiced,
                      dbo.jinvoice.JIHdr_DateShip_DT AS DateShipped, dbo.jinvoice.JIHdr_DateOrd_DT AS DateOrdered, dbo.jinvoice.JIHdr_POCust AS CustomerPO,
                      dbo.jinvoice.JIHdr_POInternal AS InternalPO, dbo.jcompany.JComp_Name AS Company,
                      dbo.jperson.JPers_NameFirst + ' ' + dbo.jperson.JPers_NameMiddle + ' ' + dbo.jperson.JPers_NameLast AS Person,
                      dbo.jinvoice.JIHdr_ShipVia AS ShipVIA, dbo.jinvoice.JIHdr_SalesAmt_d AS SalesAmt, dbo.jinvoice.JIHdr_MiscAmt_d AS MiscAmt,
                      dbo.jinvoice.JIHdr_SalesTaxAmt_d AS SalesTaxAmt, dbo.jinvoice.JIHdr_ShipAmt_d AS ShipAmt, dbo.jinvoice.JIHdr_TotalAmt_d AS TotalAmt,
                      dbo.jinvoice.JIHdr_BillToAddr01 AS BillingAddress1, dbo.jinvoice.JIHdr_BillToAddr02 AS BillingAddress2,
                      dbo.jinvoice.JIHdr_BillToAddr03 AS BillingAddress3, dbo.jinvoice.JIHdr_BillToCity AS BillingCity, dbo.jinvoice.JIHdr_BillToState AS BillingState,
                      dbo.jinvoice.JIHdr_BillToPostalCode AS BillingPostalCode, dbo.jinvoice.JIHdr_BillToCountry AS BillingCountry,
                      dbo.jinvoice.JIHdr_ShipToAddr01 AS ShippingAddress1, dbo.jinvoice.JIHdr_ShipToAddr02 AS ShippingAddress2,
                      dbo.jinvoice.JIHdr_ShipToAddr03 AS ShippingAddress3, dbo.jinvoice.JIHdr_ShipToCity AS ShippingCity,
                      dbo.jinvoice.JIHdr_ShipToState AS ShippingState, dbo.jinvoice.JIHdr_ShipToPostalCode AS ShippingPostalCode,
                      dbo.jinvoice.JIHdr_ShipToCountry AS ShippingCountry, dbo.juser.JUser_Name AS HdrCreatedBy, dbo.jinvoice.JIHdr_Created_DT AS HdrCreated,
                      juser2.JUser_Name AS HdrModifiedBy, dbo.jinvoice.JIHdr_Modified_DT AS HdrModified, dbo.jinvoice.JIHdr_Notes AS InvoiceNotes,
                      dbo.jinvoice.JIHdr_Terms AS InvoiceTerms, dbo.jinvoicelines.JILin_JInvoiceLines_UID AS LineUID, dbo.jproduct.JProd_Name AS Product,
                      dbo.jinvoicelines.JILin_QtyOrd_d AS QtyOrdered, dbo.jinvoicelines.JILin_QtyShip_d AS QtyShipped, dbo.jinvoicelines.JILin_PrcExt_d AS ExtPrice,
                      juser2.JUser_Name AS LineCreatedBy, dbo.jinvoicelines.JILin_Created_DT AS LineCreated, dbo.juser.JUser_Name AS LineModifiedBy,
                      dbo.jinvoicelines.JILin_Modified_DT AS LineModified, dbo.jinvoicelines.JILin_Desc AS Description
FROM         dbo.jinvoicelines LEFT OUTER JOIN
                      dbo.jinvoice ON dbo.jinvoice.JIHdr_JInvoice_UID = dbo.jinvoicelines.JILin_JInvoice_ID LEFT OUTER JOIN
                      dbo.jcompany ON dbo.jcompany.JComp_JCompany_UID = dbo.jinvoice.JIHdr_JCompany_ID LEFT OUTER JOIN
                      dbo.jperson ON dbo.jperson.JPers_JPerson_UID = dbo.jinvoice.JIHdr_JPerson_ID LEFT OUTER JOIN
                      dbo.jproduct ON dbo.jproduct.JProd_JProduct_UID = dbo.jinvoicelines.JILin_JProduct_ID LEFT OUTER JOIN
                      dbo.juser ON dbo.juser.JUser_JUser_UID = dbo.jinvoice.JIHdr_CreatedBy_JUser_ID LEFT OUTER JOIN
                      dbo.juser juser2 ON juser2.JUser_JUser_UID = dbo.jinvoice.JIHdr_ModifiedBy_JUser_ID LEFT OUTER JOIN
                      dbo.juser juser3 ON juser3.JUser_JUser_UID = dbo.jinvoicelines.JILin_CreatedBy_JUser_ID LEFT OUTER JOIN
                      dbo.juser juser4 ON juser4.JUser_JUser_UID = dbo.jinvoicelines.JILin_ModifiedBy_JUser_ID
WHERE     (dbo.jinvoicelines.JILin_Deleted_b <> 1) OR
                      (dbo.jinvoicelines.JILin_Deleted_b IS NULL)
ORDER BY dbo.jinvoice.JIHdr_DateInv_DT, dbo.jinvoicelines.JILin_JInvoiceLines_UID


