<?xml version="1.0"?>
<!-- *************************************************************************

Stylesheet for POSLog transformations in TxCollector
(included in stylesheet POSLog_LineItems.xsl)

written by: Josef Rüschoff (extern)

The sources are TP.net POS transactions in .xml format. 

The generated POSLog transactions are based on POSLog V2.2.1.

The stylesheet can be used for TPDotnet Versions 3.3 and 3.5

******************************************************************************
Version history:

1.3     25.09.2007:  initial version (K&OE, Austria)

1.5     08.01.2008:  <BeginDateTime> no longer generated for <LineItem> elements
        08.01.2008:  "WN:WeightFlag" attribute inserted for <Sale> and <Return> elements
        08.01.2008:  <WN:Special_Criteria> inserted for <Sale> and <Return> elements
        09.01.2008:  <PromotionID> and <WN:CampaignID> inserted in <RetailPriceModifier> 
        
1.6     07.03.2008:  bug fixing: deposit refund was not correctly handled
        07.03.2008:  bug fixing: transactions generated in debug mode where not correctly transformed

1.7     15.05.2008:  "ItemCategory" inserted as <MerchandiseHierarchy Level="ItemCategory">

1.8     15.01.2009:  <WN:EmployeeID> inserted for <Sale> and <Return> items 
        03.02.2009:  <BeginDateTime> reactivated for <Sale> and <Return> items
        03.02.2009:  <OperatorBypassApproval> inserted in <RetailPriceModifier> for OVERRIDES on DISC_INFO objects
        
1.9     02.06.2009:  attribute @Units inserted in <Quantity> entry of <Sale> and <Return> items
        03.06.2009:  attribute @WN:StatisticFlag inserted in <Sale> and <Return> line items
        03.06.2009:  <UnitListPrice> inserted, <RegularSalesUnitPrice> and <ActualSalesUnitPrice> corrected in <Sale> and <Return> line items
        03.06.2009:  bug fixing: only lTaPriceInfo = 3 means "new price"
        03.06.2009:  new <RetailPriceModifier> inserted for "Customer price"
        03.06.2009:  bug fixing: lDiscListType = 6 / 7 also define article related total discounts
        
1.10    31.08.2009:  bug fixing: dTaDiscount of ART_SALE may be a float number (leaded to NaN values) 
        31.08.2009:  bug fixing: dTotalDiscount of DISC_INFO may be a float number (leaded to NaN values) 

1.11    31.08.2009:  bug fixing to preceding change!

    Label 3.5.3

1.12    02.06.2009:  <WN:Warranty>, <WN:AddionalDesc>, <WN:BarcodeTemplate>, <WN:BonusPoints> and <WN:Measurement> inserted for <Sale> and <Return> items
        03.06.2009:  <WN:InternalTypeCode> inserted in <RetailPriceModifier>
        04.06.2009:  <TransactionLink> inserted in <Return> item
        09.10.2009:  attribute @CancelFlag in <Sale> and <Return> line items, when bIsImmediateVoid <> 0
        02.11.2009:  <PromotionID> and <WN:CampainID> inserted in <RetailPriceModifier> in case of total discount
    
    Label 3.5.4.2 (3.5.5.5, 3.7.1.7)

1.13    02.08.2010:  <WN:AddonDialog> inserted in <Sale> and <Return> items

    Label 3.9.5.0

1.14    10.12.2010:  arts namespace inserted as default namespace

1.15    05.01.2011:  add CampaignID/PromotionID/DiscountID to all Discounts if available
                     add Amount to Percentage Discounts instead of Percent node if dTotalDiscount is available
                     <Disposal> Node no longer existing in POSLog Version 2.2.1
                     add <WN:LocalStoreItem>
                     remove arts Default Namespace

1.16    06.01.2011:  <Disposal> Node reactivated

    Label 4.0 

1.17    17.01.2011:  bug fixing and extension concerning Tax handling (<TaxExemption>)

    Label 4.0.1
    
1.18    31.08.2011:  bug fixing concerning Tax handling 

    Label 4.0.2.0

1.19    21.03.2012:  bug fixing: Missing dFreeIncludedExactTaxValue or dFreeIncludedExactTaxValue nodes may lead to NaN values for <ExemptTaxAmount>

1.20    13.04.2012:  bug fixing concerning <RetailPriceModifier MethodCode=WN:NewPrice>, see MKS #880011

    Label 4.5.1.0

1.21    19.11.2012:  bug fixing concerning New Price and Customer Price, when the price encreases
        28.02.2013:  <Tax>/<SequenceNumber> now contains abs(TAX/lManualSequenceNumber), see MKS #525840

1.22	  05.04.2013: default namespace definition inserted (MKS #1066249)

    Label 5.0.0.0

1.23    11.10.2013:  elements with default values 0 and '' in the source transactions are now always correctly considered (#1209217)
    
    Label 5.0.1.6
    
1.24    05.12.2013:  added handling of lOriginalTADevice for entry method in case of void Transaction or immediate void (#417807)

1.25    03.02.2014:  extension of <LineItem> with an <Associate> item for employee info (#1308833)

1.26    06.03.2014:  <WN:CreateInfo> inserted in <LineItem>, <CustomerSurvey> and <RetailPriceModifier> (#1353785)

1.27    14.03.2014:  bug fixing to previous changes

1.28    24.03.2014:  bug fixing: <TaxRuleID> and <TaxGroupID> in <Tax> items may be empty (#1367222)
        24.03.2014:  bug fixing: <SequenceNumber> in <Tax> item may contain 'NaN' (#1367222)

1.29 22.05.2014: Added CustomerOrderForPickUp and SaleForPickUp in case of OrderItems

1.30 22.05.2014 Use Pretty Print of XMLSpy to ease MKS Diff

	Label 5.5.0.0

1.31 22.05.2014:  added handling for FixDiscInfo

1.32 22.05.2014: Added handling for ORDERED_ARTICLE & ORDERED_ARTICLE_VOID

	Label 6.0.0.0

1.33 11.08.2015: Corrected Handling for voided CustomerOrder Items (PTC #1766317)

1.34 12.08.2015: Additional Corrections for Customer Order Item Handling (PTC #1766317)

1.35 13.10.2015: Added Alpha2Code to templates for simplified customizing (#1784807)

1.36 29.01.2019: Addd Tax and exact Tax, ALDI project
*************************************************************************  -->
<xsl:stylesheet version="1.0" xmlns="http://www.nrf-arts.org/IXRetail/namespace/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:WN="http://www.wincor-nixdorf.com" exclude-result-prefixes="xsl xsi">
	<xsl:output method="xml" encoding="UTF-8"/>
	<!--**************************************************************************************************************-->
	<!--****************************     template: SaleReturnItems                        ****************************-->
	<xsl:template name="SaleReturnItems">
		<xsl:param name="TaCreateNmbr"/>
		<xsl:param name="VoidFlag"/>
		<xsl:param name="Alpha2Code"/>
		<xsl:variable name="szType1" select="name()"/>
		<xsl:variable name="DeviceFlag">
			<xsl:choose>
				<xsl:when test="lDevice and not(contains($szType1,'VOID')) and $VoidFlag = 'false'">
					<xsl:value-of select="lDevice"/>
				</xsl:when>
				<xsl:when test="lOriginalTADevice and (contains($szType1,'VOID') or $VoidFlag = 'true')">
					<xsl:value-of select="lOriginalTADevice"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>-1</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<LineItem>
			<xsl:if test="$DeviceFlag != '-1'">
				<xsl:attribute name="EntryMethod"><xsl:choose><xsl:when test="$DeviceFlag=100"><xsl:text>Keyed</xsl:text></xsl:when><xsl:when test="$DeviceFlag=101"><xsl:text>Scanned</xsl:text></xsl:when><xsl:when test="$DeviceFlag=102"><xsl:text>MSR</xsl:text></xsl:when><xsl:when test="$DeviceFlag=103"><xsl:text>Scanned</xsl:text></xsl:when><xsl:when test="$DeviceFlag=104"><xsl:text>Keyed</xsl:text></xsl:when><xsl:when test="$DeviceFlag=105"><xsl:text>Automatic</xsl:text></xsl:when><xsl:when test="$DeviceFlag=106"><xsl:text>Automatic</xsl:text></xsl:when><xsl:when test="$DeviceFlag=0"><xsl:text>Keyed</xsl:text></xsl:when><xsl:otherwise><xsl:text>Other</xsl:text></xsl:otherwise></xsl:choose></xsl:attribute>
			</xsl:if>
			<xsl:if test="contains($szType1,'VOID')">
				<xsl:attribute name="VoidFlag">true</xsl:attribute>
			</xsl:if>
			<xsl:if test="contains($szType1,'IMMEDIATE') or bIsImmediateVoid != 0">
				<xsl:attribute name="CancelFlag">true</xsl:attribute>
			</xsl:if>
			<xsl:if test="contains(name(),'STAT')">
				<xsl:attribute name="WN:StatisticFlag">true</xsl:attribute>
			</xsl:if>
			<SequenceNumber>
				<xsl:value-of select="Hdr/lTaSeqNmbr"/>
			</SequenceNumber>
			<!--<BeginDateTime>
        <xsl:call-template name="formatdatetime">
          <xsl:with-param name="datetime" select="Hdr/szTaCreatedDate"/>
        </xsl:call-template>
      </BeginDateTime>-->
			<xsl:if test="szDate != ''">
				<BeginDateTime>
					<xsl:call-template name="formatdatetime">
						<xsl:with-param name="datetime" select="szDate"/>
					</xsl:call-template>
				</BeginDateTime>
			</xsl:if>
			<xsl:call-template name="Override">
				<xsl:with-param name="TaCreateNmbr" select="$TaCreateNmbr"/>
				<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
			</xsl:call-template>
			<xsl:variable name="RefLineItem">
				<xsl:choose>
					<xsl:when test="Hdr/lTaRefToCreateNmbr">
						<xsl:value-of select="Hdr/lTaRefToCreateNmbr"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="0"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>			
			<xsl:choose>
				<!-- Ordered Article -->
				<xsl:when test="contains($szType1, 'ORDERED_ARTICLE')">
					<xsl:variable name="ItemTypeValue">
						<xsl:choose>
							<xsl:when test="dUnitPrice &lt; 0">
								<xsl:value-of select="'WN:NegativeItem'"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'Stock'"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<CustomerOrderForPickUp>
						<xsl:call-template name="OrderedArticle">
							<xsl:with-param name="ItemTypeValue" select="$ItemTypeValue"/>
							<xsl:with-param name="TaCreateNmbr" select="$TaCreateNmbr"/>
							<xsl:with-param name="RefLineItem" select="$RefLineItem"/>
							<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
						</xsl:call-template>
					</CustomerOrderForPickUp>
				</xsl:when>
				<xsl:when test="contains($szType1,'RETURN') or ARTICLE/bIsDepositItem != 0 and $RefLineItem = 0 and dTaPrice &lt; 0">
					<!-- remark: empties are returned in TP.net as SALE with negative prices!! -->
					<Return>
						<xsl:variable name="ItemTypeValue">
							<xsl:choose>
								<xsl:when test="ARTICLE/bIsDepositItem != 0 and $RefLineItem &gt; 0">
									<xsl:value-of select="'Deposit'"/>
								</xsl:when>
								<xsl:when test="ARTICLE/bIsDepositItem != 0 and $RefLineItem = 0">
									<xsl:value-of select="'DepositRefund'"/>
								</xsl:when>
								<xsl:when test="dTaPrice &lt; 0">
									<xsl:value-of select="'WN:NegativeItem'"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="'Stock'"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:call-template name="returnsale">
							<xsl:with-param name="ItemTypeValue" select="$ItemTypeValue"/>
							<xsl:with-param name="TaCreateNmbr" select="$TaCreateNmbr"/>
							<xsl:with-param name="RefLineItem" select="$RefLineItem"/>
							<xsl:with-param name="SaleOrReturn" select="'Return'"/>
							<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
						</xsl:call-template>
						<!--<xsl:if test ="$ItemTypeValue != 'WN:NegativeItem'">
              <Disposal>
                <xsl:attribute name="Method">ReturnToStock</xsl:attribute>
              </Disposal>
            </xsl:if>-->
					</Return>
				</xsl:when>				
				<xsl:when test="Hdr/szTaRefTaObject = 'CUSTOMER_ORDER' or (contains($szType1, 'ART_LINE_VOID') and ./../*/Hdr[lTaCreateNmbr=$RefLineItem]/../Hdr/szTaRefTaObject = 'CUSTOMER_ORDER')">
					<xsl:variable name="ItemTypeValue">
						<xsl:choose>
							<xsl:when test="dTaPrice &lt; 0">
								<xsl:value-of select="'WN:NegativeItem'"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'Stock'"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<!-- CustomerOrderForPickUp with ART_SALE, ART_LINE_VOID, STAT_LINE_VOID-->				
					<xsl:variable name="OrderNumber">
						<xsl:choose>
							<!-- Directly referenced to Order -->
							<xsl:when test="./../*/Hdr[lTaCreateNmbr=$RefLineItem]/../szDocumentNumber">
								<xsl:value-of select="./../*/Hdr[lTaCreateNmbr=$RefLineItem]/../szDocumentNumber"/>								
							</xsl:when>
							<!-- Referenced to Order one step above (voided item, set item) -->
							<xsl:when test="./../*/Hdr[lTaCreateNmbr=../../*/Hdr[lTaCreateNmbr=$RefLineItem]/lTaRefToCreateNmbr]/../szDocumentNumber">
								<xsl:value-of select="./../*/Hdr[lTaCreateNmbr=../../*/Hdr[lTaCreateNmbr=$RefLineItem]/lTaRefToCreateNmbr]/../szDocumentNumber"/>
							</xsl:when>
							<xsl:otherwise/>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="OrderShopNumber">
						<xsl:choose>
							<!-- Directly referenced to Order -->
							<xsl:when test="./../*/Hdr[lTaCreateNmbr=$RefLineItem]/../szShopNumber">
								<xsl:value-of select="./../*/Hdr[lTaCreateNmbr=$RefLineItem]/../szShopNumber"/>								
							</xsl:when>
							<!-- Referenced to Order one step above (voided item, set item) -->
							<xsl:when test="./../*/Hdr[lTaCreateNmbr=../../*/Hdr[lTaCreateNmbr=$RefLineItem]/lTaRefToCreateNmbr]/../szShopNumber">
								<xsl:value-of select="./../*/Hdr[lTaCreateNmbr=../../*/Hdr[lTaCreateNmbr=$RefLineItem]/lTaRefToCreateNmbr]/../szShopNumber"/>
							</xsl:when>
							<xsl:otherwise/>
						</xsl:choose>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="Hdr/bTaValid = 0">
							<CustomerOrderForPickUp>
								<xsl:call-template name="returnsale">
									<xsl:with-param name="ItemTypeValue" select="$ItemTypeValue"/>
									<xsl:with-param name="TaCreateNmbr" select="$TaCreateNmbr"/>
									<xsl:with-param name="RefLineItem" select="$RefLineItem"/>
									<xsl:with-param name="SaleOrReturn" select="'Sale'"/>
									<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
								</xsl:call-template>
								<xsl:if test="$OrderNumber !=''">								
									<InventoryReservationID>
										<xsl:value-of select="$OrderNumber"/>
									</InventoryReservationID>
									<From>
										<xsl:value-of select="$OrderShopNumber"/>
									</From>
								</xsl:if>
							</CustomerOrderForPickUp>
						</xsl:when>
						<xsl:otherwise>
							<SaleForPickUp>
								<xsl:call-template name="returnsale">
									<xsl:with-param name="ItemTypeValue" select="$ItemTypeValue"/>
									<xsl:with-param name="TaCreateNmbr" select="$TaCreateNmbr"/>
									<xsl:with-param name="RefLineItem" select="$RefLineItem"/>
									<xsl:with-param name="SaleOrReturn" select="'Sale'"/>
									<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
								</xsl:call-template>
								<xsl:if test="$OrderNumber != ''">								
									<InventoryReservationID>
										<xsl:value-of select="$OrderNumber"/>
									</InventoryReservationID>
									<From>
										<xsl:value-of select="$OrderShopNumber"/>
									</From>
								</xsl:if>
							</SaleForPickUp>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<Sale>
						<xsl:variable name="ItemTypeValue">
							<xsl:choose>
								<xsl:when test="ARTICLE/bIsDepositItem != 0">
									<xsl:value-of select="'Deposit'"/>
								</xsl:when>
								<xsl:when test="dTaPrice &lt; 0">
									<xsl:value-of select="'WN:NegativeItem'"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="'Stock'"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:call-template name="returnsale">
							<xsl:with-param name="ItemTypeValue" select="$ItemTypeValue"/>
							<xsl:with-param name="TaCreateNmbr" select="$TaCreateNmbr"/>
							<xsl:with-param name="RefLineItem" select="$RefLineItem"/>
							<xsl:with-param name="SaleOrReturn" select="'Sale'"/>
							<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
						</xsl:call-template>
					</Sale>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="CreateInfo">
				<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
			</xsl:call-template>
		</LineItem>
	</xsl:template>
	<!--*********************************************************************************************************-->
	<!--****************************               template: returnsale              ****************************-->
	<xsl:template name="returnsale">
		<xsl:param name="ItemTypeValue"/>
		<xsl:param name="TaCreateNmbr"/>
		<xsl:param name="RefLineItem"/>
		<xsl:param name="SaleOrReturn"/>
		<xsl:param name="Alpha2Code"/>
		<xsl:attribute name="ItemType"><xsl:value-of select="$ItemTypeValue"/></xsl:attribute>
		<xsl:if test="ARTICLE/szPieceUnitOfMeasureCode = 'WE'">
			<xsl:attribute name="WN:WeightFlag"><xsl:text>true</xsl:text></xsl:attribute>
		</xsl:if>
		<ItemID>
			<xsl:value-of select="ARTICLE/szItemID"/>
		</ItemID>
				
		<xsl:if test="szItemLookupCode != ''">
			<POSIdentity POSIDType="EAN">
				<POSItemID>
					<xsl:value-of select="szItemLookupCode"/>
				</POSItemID>
			</POSIdentity>
		</xsl:if>
		<xsl:if test="ARTICLE/szPOSItemID != ''">
			<POSIdentity POSIDType="POSItemID">
				<POSItemID>
					<xsl:value-of select="ARTICLE/szPOSItemID"/>
				</POSItemID>
			</POSIdentity>
		</xsl:if>
		<xsl:if test="ARTICLE/szMerchHierarchyLevelCode != ''">
			<MerchandiseHierarchy Level="MerchandiseHierarchyLevel">
				<xsl:value-of select="ARTICLE/szMerchHierarchyLevelCode"/>
			</MerchandiseHierarchy>
		</xsl:if>
		<xsl:if test="ARTICLE/lMerchandiseStructureID != 0">
			<MerchandiseHierarchy Level="MerchandiseStructure">
				<xsl:value-of select="ARTICLE/lMerchandiseStructureID"/>
			</MerchandiseHierarchy>
		</xsl:if>
		<xsl:if test="ARTICLE/szPOSDepartmentID != ''">
			<MerchandiseHierarchy Level="POSDepartment">
				<xsl:value-of select="ARTICLE/szPOSDepartmentID"/>
			</MerchandiseHierarchy>
		</xsl:if>
		<xsl:if test="ARTICLE/szItemCategoryTypeCode != ''">
			<MerchandiseHierarchy Level="ItemCategory">
				<xsl:value-of select="ARTICLE/szItemCategoryTypeCode"/>
			</MerchandiseHierarchy>
		</xsl:if>
		<xsl:if test="ARTICLE/szAccountingID">
			<ZARTTYPE>
				<xsl:value-of select="ARTICLE/szAccountingID"/>
			</ZARTTYPE>
		</xsl:if>
		
		<!-- 增加礼品卡商品标识  by zengling 2020/08/18-->
		<xsl:if test="ARTICLE/szAccountingID = 'Z009'">
			<ZLP>
				<xsl:value-of select="1"/>
			</ZLP>
		</xsl:if>
		
		<xsl:choose>
			<xsl:when test="ARTICLE/bTxPluNotFound != 0">
				<ItemNotOnFileFlag>true</ItemNotOnFileFlag>
			</xsl:when>
			<xsl:when test="../PLU_NOT_FOUND">
				<xsl:variable name="ItemLookupCode">
					<xsl:value-of select="szItemLookupCode"/>
				</xsl:variable>
				<xsl:for-each select="//PLU_NOT_FOUND[szItemLookupCode = $ItemLookupCode]">
					<ItemNotOnFileFlag>true</ItemNotOnFileFlag>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>
		<Description>
			<xsl:value-of select="ARTICLE/szDesc"/>
		</Description>
		<xsl:if test="ARTICLE/dPackingUnitPriceAmount != 0">
			<UnitListPrice>
				<xsl:call-template name="AbsNumber">
					<xsl:with-param name="number" select="ARTICLE/dPackingUnitPriceAmount"/>
				</xsl:call-template>
			</UnitListPrice>
		</xsl:if>
		<!-- 
    <xsl:if test="ARTICLE/dPackingUnitPriceAmount != 0">
      <xsl:variable name="PackingResult1">
        <xsl:choose>
          <xsl:when test="ARTICLE/dPackingUnitPriceAmount != 0">
            <xsl:value-of select="ARTICLE/dPackingUnitPriceAmount"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="dTaPrice"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
    <xsl:if test="$PackingResult1 != 0">
        <RegularSalesUnitPrice>
          <xsl:call-template name="AbsNumber">
            <xsl:with-param name="number" select="$PackingResult1"/>
          </xsl:call-template>
        </RegularSalesUnitPrice>
      </xsl:if>
    </xsl:if>  -->
		<xsl:variable name="OrgPrice">
			<xsl:choose>
				<xsl:when test="dOrgPrice and dOrgPrice &gt; 0">
					<xsl:value-of select="dOrgPrice"/>
				</xsl:when>
				<xsl:when test="dOrgPrice and dOrgPrice &lt; 0">
					<xsl:value-of select="dOrgPrice * (-1)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="0"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="TaPrice">
			<xsl:choose>
				<xsl:when test="dTaPrice and dTaPrice &gt; 0">
					<xsl:value-of select="dTaPrice"/>
				</xsl:when>
				<xsl:when test="dTaPrice and dTaPrice &lt; 0">
					<xsl:value-of select="dTaPrice * (-1)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="0"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="BasePrice">
			<xsl:choose>
				<xsl:when test="$OrgPrice &gt; 0">
					<xsl:value-of select="$OrgPrice"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$TaPrice"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<RegularSalesUnitPrice>
			<xsl:choose>
				<xsl:when test="dCustomerPriceDifference != 0">
					<xsl:call-template name="AbsNumber">
						<xsl:with-param name="number" select="$BasePrice + dCustomerPriceDifference"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="AbsNumber">
						<xsl:with-param name="number" select="$BasePrice"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</RegularSalesUnitPrice>
		<xsl:variable name="TaQty">
			<xsl:choose>
				<xsl:when test="dTaQty">
					<xsl:value-of select="dTaQty"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="TaTotal">
			<xsl:choose>
				<xsl:when test="dTaTotal">
					<xsl:value-of select="dTaTotal"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="Discount">
			<xsl:choose>
				<xsl:when test="dTaDiscount">
					<xsl:call-template name="AbsNumber">
						<xsl:with-param name="number" select="dTaDiscount"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- 使用  $Discount * dTaQty 存在小数误差，所以将 取绝对值方法 AbsNumber 的小数位数增加至6位, 注意TaQty需保留正负号 -->		
		<xsl:variable name="totalDiscount">
				<xsl:value-of select="$Discount * $TaQty"/>
		</xsl:variable>
		
		<ActualSalesUnitPrice>
			<xsl:call-template name="AbsNumber">
				<xsl:with-param name="number" select="format-number($TaPrice - $Discount, '#0.##')"/>
			</xsl:call-template>
		</ActualSalesUnitPrice>
		
		<SalesAmount>
			<xsl:call-template name="AbsNumber">
						<xsl:with-param name="number" select="format-number($TaTotal, '#0.##')"/>
					</xsl:call-template>
		</SalesAmount>

		<ExtendedAmount>
			<xsl:choose>
				<xsl:when test="dTaQty != 0">
					<!-- there are no discounts with negative prices! -->
					<xsl:call-template name="AbsNumber">
						<!-- <xsl:with-param name="number" select="format-number($TaTotal - $Discount * dTaQty, '#0.##')"/> -->
						<xsl:with-param name="number" select="format-number($TaTotal - $totalDiscount, '#0.##')"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="AbsNumber">
						<xsl:with-param name="number" select="format-number($TaTotal, '#0.##')"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</ExtendedAmount>
		<xsl:if test="$Discount != 0">
			<DiscountAmount>
				<xsl:call-template name="AbsNumber">
					<xsl:with-param name="number" select="format-number($Discount, '#0.##')"/>
				</xsl:call-template>
			</DiscountAmount>
			<ExtendedDiscountAmount>
				<xsl:call-template name="AbsNumber">
					<!-- <xsl:with-param name="number" select="format-number($Discount * $TaQty, '#0.##')"/> -->
					<xsl:with-param name="number" select="format-number($totalDiscount, '#0.##')"/>
				</xsl:call-template>
			</ExtendedDiscountAmount>
		</xsl:if>
		
		
		<!--<xsl:variable name="LinePercent">
			<xsl:choose>
				<xsl:when test="following-sibling::TAX_ART[1]/TAX/dPercent != ''" >
					<xsl:value-of select="following-sibling::TAX_ART[1]/TAX/dPercent"/>
					</xsl:when>
				<xsl:otherwise>
				  <xsl:value-of select="0"/>
				</xsl:otherwise>
			</xsl:choose>		
		</xsl:variable> -->
		
		<xsl:variable name="LinePercent">
			<xsl:for-each select="following-sibling::TAX_ART[Hdr/lTaRefToCreateNmbr=$TaCreateNmbr]">
				<xsl:choose>
					<xsl:when test="TAX/dPercent">
						<xsl:value-of select="TAX/dPercent"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="0"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>				
		</xsl:variable> 
		
		<xsl:if test="$TaTotal != 0">			
			<xsl:variable name="LineAmountTax">
				<xsl:value-of select="format-number($LinePercent div 100, '#0.##')"/>
			</xsl:variable>
			
			<xsl:variable name="LineAmountTaxCalculate">
				<xsl:choose>
					<xsl:when test="$LinePercent != 0" >
						<xsl:value-of select="format-number($TaTotal div (($LinePercent + 100) div 100) * $LineAmountTax , '#0.##')"/>
					</xsl:when>
					<xsl:otherwise>
					  <xsl:value-of select="0"/>
					</xsl:otherwise>
				</xsl:choose>						
			</xsl:variable>
			<xsl:variable name="amountWithoutTax">
				<xsl:value-of select="format-number($TaTotal - $LineAmountTaxCalculate, '#0.##')"/>				
			</xsl:variable>

			<xsl:variable name="lineTotalDiscountTaxAmountCalculate">
				<xsl:choose>
					<xsl:when test="$LinePercent != 0" >
						<xsl:value-of select="format-number($totalDiscount div (($LinePercent + 100) div 100) * $LineAmountTax , '#0.##')"/>
					</xsl:when>
					<xsl:otherwise>
					  <xsl:value-of select="0"/>
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:variable>
			<xsl:variable name="lineTotalDiscountWithoutTaxAmount">
				<xsl:value-of select="format-number($totalDiscount - $lineTotalDiscountTaxAmountCalculate, '#0.##')"/>				
			</xsl:variable>
			
			<!-- 从TA中直接获商品行的相关税额 2020/12/21 by zengling -->			
			<!-- 商品行总折扣的税额 -->
			<lineTotalDiscountTaxAmount>
				<xsl:choose>
					<xsl:when test="dTotalDiscountTaxAmount = 0">
						<xsl:value-of select="0"/>
					</xsl:when>
					<xsl:when test="dTotalDiscountTaxAmount != 0">
						<xsl:call-template name="AbsNumber">
							<xsl:with-param name="number" select="format-number(dTotalDiscountTaxAmount, '#0.##')"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="AbsNumber">
							<xsl:with-param name="number" select="$lineTotalDiscountTaxAmountCalculate"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>				
			</lineTotalDiscountTaxAmount>
			
			<!--商品行总折扣的不含税金额 -->
			<lineTotalDiscountWithoutTaxAmount>
				<xsl:choose>
					<xsl:when test="dTotalDiscountWithoutTaxAmount = 0">
						<xsl:value-of select="0"/>
					</xsl:when>
					<xsl:when test="dTotalDiscountWithoutTaxAmount != 0">
						<xsl:call-template name="AbsNumber">
							<xsl:with-param name="number" select="format-number(dTotalDiscountWithoutTaxAmount, '#0.##')"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="AbsNumber">
							<xsl:with-param name="number" select="$lineTotalDiscountWithoutTaxAmount"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>	
			</lineTotalDiscountWithoutTaxAmount>
			
			<!--商品行总折后价的税额 -->
			<lineTotalTaxAmount>
				<xsl:choose>
					<xsl:when test="lineTotalTaxAmount = 0">
						<xsl:value-of select="0"/>
					</xsl:when>
					<xsl:when test="lineTotalTaxAmount != 0">
						<xsl:call-template name="AbsNumber">
							<xsl:with-param name="number" select="format-number(lineTotalTaxAmount, '#0.##')"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="AbsNumber">
							<xsl:with-param name="number" select="format-number($LineAmountTaxCalculate - $lineTotalDiscountTaxAmountCalculate, '#0.##')"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>			
			</lineTotalTaxAmount>
			
			<!--商品行原价的税额 -->
			<taxAmount>
				<xsl:choose>
					<xsl:when test="dTaxAmount = 0">
						<xsl:value-of select="0"/>
					</xsl:when>
					<xsl:when test="dTaxAmount != 0">
						<xsl:call-template name="AbsNumber">
							<xsl:with-param name="number" select="format-number(dTaxAmount, '#0.##')"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="AbsNumber">
							<xsl:with-param name="number" select="$LineAmountTaxCalculate"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>			
			</taxAmount>
			
			<!--商品行原价的不含税金额 -->
			<amountWithoutTax>
				<xsl:choose>
					<xsl:when test="dWithoutTaxAmount = 0">
						<xsl:value-of select="0"/>
					</xsl:when>
					<xsl:when test="dWithoutTaxAmount != 0">
						<xsl:call-template name="AbsNumber">
							<xsl:with-param name="number" select="format-number(dWithoutTaxAmount, '#0.##')"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="AbsNumber">
							<xsl:with-param name="number" select="$amountWithoutTax"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>				
			</amountWithoutTax>
			
		</xsl:if>


		<xsl:if test="dTaQty != 0">
			<Quantity>
				<xsl:if test="dQuantityEntry != 0">
					<xsl:attribute name="Units"><xsl:call-template name="AbsNumber"><xsl:with-param name="number" select="dQuantityEntry"/></xsl:call-template></xsl:attribute>
				</xsl:if>
				<xsl:if test="ARTICLE/szPriceUnitOfMeasureName != ''">
					<xsl:attribute name="UnitOfMeasureCode"><xsl:value-of select="ARTICLE/szPriceUnitOfMeasureName"/></xsl:attribute>
				</xsl:if>
				<xsl:call-template name="AbsNumber">
					<xsl:with-param name="number" select="dTaQty"/>
				</xsl:call-template>
			</Quantity>
		</xsl:if>
		<xsl:if test="lEmployeeID != 0">
			<Associate>
				<AssociateID>
					<xsl:if test="szEmployeeDescription != ''">
						<xsl:attribute name="OperatorName"><xsl:value-of select="szEmployeeDescription"/></xsl:attribute>
					</xsl:if>
					<xsl:attribute name="EmployeeID"><xsl:value-of select="lEmployeeID"/></xsl:attribute>
				</AssociateID>
			</Associate>
		</xsl:if>
		<!--RetailPriceModifier Discounts-->
		<xsl:if test="dCustomerPriceDifference != 0">
			<!-- customer price for this article (always occurs as first entry, that means before "New Price") -->
			<RetailPriceModifier MethodCode="WN:CustomerPrice">
				<SequenceNumber>
					<xsl:value-of select="$TaCreateNmbr - 1"/>
				</SequenceNumber>
				<Amount Action="Replace">
					<xsl:call-template name="AbsNumber">
						<xsl:with-param name="number" select="$BasePrice"/>
					</xsl:call-template>
				</Amount>
				<PreviousPrice>
					<xsl:call-template name="AbsNumber">
						<xsl:with-param name="number" select="$BasePrice + dCustomerPriceDifference"/>
					</xsl:call-template>
				</PreviousPrice>
				<ReasonCode>Customer_Price</ReasonCode>
				<xsl:call-template name="CreateInfo">
					<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
				</xsl:call-template>
			</RetailPriceModifier>
		</xsl:if>
		<xsl:if test="lTaPriceInfo = 3">
			<!-- new price for this article -->
			<RetailPriceModifier MethodCode="WN:NewPrice">
				<SequenceNumber>
					<xsl:value-of select="$TaCreateNmbr"/>
				</SequenceNumber>
				<Amount Action="Replace">
					<xsl:choose >
					  <xsl:when test="dTaPrice != ''">
						 <xsl:call-template name="AbsNumber">
						  <xsl:with-param name="number" select="format-number(dTaPrice, '#0.##')"/>
						 </xsl:call-template>
					  </xsl:when>
					  <xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</Amount>
				<xsl:if test="$OrgPrice != 0">
					<PreviousPrice>
						<xsl:call-template name="AbsNumber">
							<xsl:with-param name="number" select="$OrgPrice"/>
						</xsl:call-template>
					</PreviousPrice>
				</xsl:if>
				<ReasonCode>New_Price</ReasonCode>
				<xsl:call-template name="CreateInfo">
					<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
				</xsl:call-template>
			</RetailPriceModifier>
		</xsl:if>
		<!-- <xsl:for-each select="//DISC_INFO[Hdr/lTaRefToCreateNmbr=$TaCreateNmbr and lDiscListType != 15]">  -->
		<xsl:for-each select="(following-sibling::DISC_INFO | following-sibling::FIX_DISC_INFO )[Hdr/lTaRefToCreateNmbr=$TaCreateNmbr and lDiscListType != 15]">
			<xsl:if test="lDiscListType &lt; 4">
				<!-- manual discount for this article -->
				<RetailPriceModifier MethodCode="PriceOverride">
					<SequenceNumber>
						<xsl:value-of select="Hdr/lTaCreateNmbr"/>
					</SequenceNumber>
					<xsl:choose>
						<xsl:when test="lDiscListType = 1">
							<xsl:choose>
								<xsl:when test="dTotalDiscount != 0">
									<Amount Action="Subtract">
										<xsl:call-template name="AbsNumber">
											<xsl:with-param name="number" select="format-number(dTotalDiscount, '#0.##')"/>
										</xsl:call-template>
									</Amount>
								</xsl:when>
								<xsl:otherwise>
									<Percent Action="Subtract">
										<xsl:call-template name="AbsNumber">
											<xsl:with-param name="number" select="dDiscValue"/>
										</xsl:call-template>
									</Percent>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="lDiscListType = 2">
							<Amount Action="Subtract">
								<xsl:call-template name="AbsNumber">
									<xsl:with-param name="number" select="format-number(dDiscValue, '#0.##')"/>
								</xsl:call-template>
							</Amount>
						</xsl:when>
						<xsl:otherwise>
							<Amount Action="Replace">
								<xsl:call-template name="AbsNumber">
									<xsl:with-param name="number" select="format-number(dDiscValue, '#0.##')"/>
								</xsl:call-template>
							</Amount>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="szCampaignPromotionID != ''">
						<PromotionID>
							<xsl:value-of select="szCampaignPromotionID"/>
						</PromotionID>
					</xsl:if>
					<xsl:if test="szDiscountID != ''">
						<PriceDerivationRule>
							<PriceDerivationRuleID>
								<xsl:value-of select="szDiscountID"/>
							</PriceDerivationRuleID>
						</PriceDerivationRule>
					</xsl:if>
					<ReasonCode>
						<xsl:value-of select="szDiscDesc"/>
					</ReasonCode>
					<xsl:call-template name="Override">
						<xsl:with-param name="TaCreateNmbr" select="Hdr/lTaCreateNmbr"/>
						<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
					</xsl:call-template>
					<xsl:if test="szGlobalCampaignID != ''">
						<WN:CampaignID>
							<xsl:value-of select="szGlobalCampaignID"/>
						</WN:CampaignID>
					</xsl:if>
					<WN:InternalTypeCode>
						<xsl:value-of select="lDiscListType"/>
					</WN:InternalTypeCode>
					<xsl:call-template name="CreateInfo">
						<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
					</xsl:call-template>
				</RetailPriceModifier>
			</xsl:if>
			<xsl:if test="lDiscListType &gt; 10">
				<!-- automatic discounts for this article -->
				<RetailPriceModifier MethodCode="PriceRule">
					<SequenceNumber>
						<xsl:value-of select="Hdr/lTaCreateNmbr"/>
					</SequenceNumber>
					<xsl:variable name="TotalDiscount">
						<xsl:choose>
							<xsl:when test="dTotalDiscount">
								<xsl:call-template name="AbsNumber">
									<xsl:with-param name="number" select="dTotalDiscount"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>0</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<Amount Action="Subtract">
						<xsl:call-template name="AbsNumber">
							<xsl:with-param name="number" select="format-number($TotalDiscount div $TaQty, '#0.##')"/>
						</xsl:call-template>
					</Amount>
					<discountAmount>
						<xsl:call-template name="AbsNumber">
							<xsl:with-param name="number" select="format-number($TotalDiscount, '#0.##')"/>
						</xsl:call-template>
				    </discountAmount>												
											
					<xsl:variable name="calculate">
						<xsl:value-of select="format-number($LinePercent div 100, '#0.##')"/>
					</xsl:variable>
					<xsl:variable name="lineTotalTaxAmount">
						<xsl:choose>
							<xsl:when test="$LinePercent != 0" >
								<xsl:value-of select="format-number($TotalDiscount div (($LinePercent + 100) div 100) * $calculate, '#0.##')"/>
							</xsl:when>
							<xsl:otherwise>
							  <xsl:value-of select="0"/>
							</xsl:otherwise>
						 </xsl:choose>						
					</xsl:variable>	
					
					<xsl:variable name="lineTotalAmountWithoutTax">
						<xsl:value-of select="format-number($TotalDiscount - $lineTotalTaxAmount, '#0.##')"/>				
					</xsl:variable>	

					<!-- 从TA中获取折扣的税额 2020/12/21 by zengling -->
					<lineTotalTaxAmount>
						<xsl:choose>
							<xsl:when test="dTotalDiscountTaxAmount = 0">
								<xsl:value-of select="0"/>
							</xsl:when>
							<xsl:when test="dTotalDiscountTaxAmount != 0">
								 <xsl:call-template name="AbsNumber">
									<xsl:with-param name="number" select="format-number(dTotalDiscountTaxAmount, '#0.##')"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
							    <xsl:call-template name="AbsNumber">
									<xsl:with-param name="number" select="$lineTotalTaxAmount"/>
								</xsl:call-template>
							</xsl:otherwise>
						 </xsl:choose>						
					</lineTotalTaxAmount>						
					<lineTotalAmountWithoutTax>
						<xsl:choose>
							<xsl:when test="dTotalDiscountWithoutTaxAmount = 0">
								<xsl:value-of select="0"/>
							</xsl:when>
							<xsl:when test="dTotalDiscountWithoutTaxAmount != 0">
								 <xsl:call-template name="AbsNumber">
									<xsl:with-param name="number" select="format-number(dTotalDiscountWithoutTaxAmount, '#0.##')"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
							    <xsl:call-template name="AbsNumber">
									<xsl:with-param name="number" select="$lineTotalAmountWithoutTax"/>
								</xsl:call-template>
							</xsl:otherwise>
						 </xsl:choose>						
					</lineTotalAmountWithoutTax>
					
					<xsl:if test="szCampaignPromotionID != ''">
						<PromotionID>
							<xsl:value-of select="szCampaignPromotionID"/>
						</PromotionID>
					</xsl:if>
					
					<!-- 单品促销ID需截取-->
					<PriceDerivationRule>																			
						<xsl:choose>
							<!-- 会员权益折扣-->
							<xsl:when test="lManualDiscountID != ''">
								<PriceDerivationRuleID>
									<xsl:value-of select="lManualDiscountID"/>
								</PriceDerivationRuleID>
							</xsl:when>
							<xsl:when test="contains(szDiscountID,'_')">
								<PriceDerivationRuleID>
								<xsl:value-of select="substring-before(szDiscountID, '_')"/>
								</PriceDerivationRuleID>
							</xsl:when>
							<xsl:otherwise>
								<PriceDerivationRuleID>
									<xsl:value-of select="szDiscountID"/>
								</PriceDerivationRuleID>
							</xsl:otherwise>
						</xsl:choose>
					</PriceDerivationRule>		
					
					<ReasonCode>
						<xsl:value-of select="szDiscDesc"/>
					</ReasonCode>
					<xsl:call-template name="Override">
						<xsl:with-param name="TaCreateNmbr" select="Hdr/lTaCreateNmbr"/>
						<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
					</xsl:call-template>
					<xsl:if test="szGlobalCampaignID != ''">
						<WN:CampaignID>
							<xsl:value-of select="szGlobalCampaignID"/>
						</WN:CampaignID>
					</xsl:if>
					<WN:InternalTypeCode>
						<xsl:value-of select="lDiscListType"/>
					</WN:InternalTypeCode>
					<xsl:call-template name="CreateInfo">
						<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
					</xsl:call-template>
				</RetailPriceModifier>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="( following-sibling::DISC_INFO | following-sibling::FIX_DISC_INFO )[Hdr/lTaRefToCreateNmbr=$TaCreateNmbr and (lDiscListType = 15 or lDiscListType = 6 or lDiscListType = 7)]">
			<!-- total discount for this article -->
			<RetailPriceModifier MethodCode="WN:TotalDiscount">
				<SequenceNumber>
					<xsl:value-of select="Hdr/lTaCreateNmbr"/>
				</SequenceNumber>
				<xsl:variable name="TotalDiscount">
					<xsl:choose>
						<xsl:when test="dTotalDiscount">
							<xsl:call-template name="AbsNumber">
								<xsl:with-param name="number" select="dTotalDiscount"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<Amount Action="Subtract">
					<xsl:call-template name="AbsNumber">
						<xsl:with-param name="number" select="format-number($TotalDiscount div $TaQty, '#0.##')"/>
					</xsl:call-template>
				</Amount>
				<discountAmount>
					<xsl:call-template name="AbsNumber">
						<xsl:with-param name="number" select="format-number($TotalDiscount, '#0.##')"/>
					</xsl:call-template>
				</discountAmount>
								
				<xsl:variable name="LinePercentCalculate">
					<xsl:value-of select="format-number($LinePercent div 100, '#0.##')"/>
				</xsl:variable>
				<xsl:variable name="lineTotalTaxAmount">
					<xsl:choose>
						<xsl:when test="$LinePercent != 0" >
						    <xsl:value-of select="format-number( $TotalDiscount div (($LinePercent + 100) div 100) * $LinePercentCalculate , '#0.##')"/>
						</xsl:when>
						<xsl:otherwise>
						  <xsl:value-of select="0"/>
						</xsl:otherwise>
					 </xsl:choose>						
				</xsl:variable>	
				<xsl:variable name="lineTotalAmountWithoutTax">
					<xsl:value-of select="format-number($TotalDiscount - $lineTotalTaxAmount, '#0.##')"/>					
				</xsl:variable>				        
				<!-- 从TA中获取折扣的税额 2020/12/21 by zengling -->
				<lineTotalTaxAmount>
					<xsl:choose>
						<xsl:when test="dTotalDiscountTaxAmount = 0">
							<xsl:value-of select="0"/>
						</xsl:when>
						<xsl:when test="dTotalDiscountTaxAmount != 0">
							 <xsl:call-template name="AbsNumber">
								<xsl:with-param name="number" select="format-number(dTotalDiscountTaxAmount, '#0.##')"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="AbsNumber">
								<xsl:with-param name="number" select="$lineTotalTaxAmount"/>
							</xsl:call-template>
						</xsl:otherwise>
					 </xsl:choose>						
				</lineTotalTaxAmount>						
				<lineTotalAmountWithoutTax>
					<xsl:choose>
						<xsl:when test="dTotalDiscountWithoutTaxAmount = 0">
							<xsl:value-of select="0"/>
						</xsl:when>
						<xsl:when test="dTotalDiscountWithoutTaxAmount != 0">
							 <xsl:call-template name="AbsNumber">
								<xsl:with-param name="number" select="format-number(dTotalDiscountWithoutTaxAmount, '#0.##')"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="AbsNumber">
								<xsl:with-param name="number" select="$lineTotalAmountWithoutTax"/>
							</xsl:call-template>
						</xsl:otherwise>
					 </xsl:choose>						
				</lineTotalAmountWithoutTax>
					
				<xsl:if test="szCampaignPromotionID != ''">
					<PromotionID>
						<xsl:value-of select="szCampaignPromotionID"/>
					</PromotionID>
				</xsl:if>
				
				<!-- 单品促销ID需截取-->
				<PriceDerivationRule>
					<xsl:choose>
						<!-- 会员权益折扣-->
						<xsl:when test="lManualDiscountID != ''">
							<PriceDerivationRuleID>
								<xsl:value-of select="lManualDiscountID"/>
							</PriceDerivationRuleID>
						</xsl:when>
						<xsl:when test="contains(szDiscountID,'_')">
							<PriceDerivationRuleID>
							<xsl:value-of select="substring-before(szDiscountID, '_')"/>
							</PriceDerivationRuleID>
						</xsl:when>
						<xsl:otherwise>
							<PriceDerivationRuleID>
								<xsl:value-of select="szDiscountID"/>
							</PriceDerivationRuleID>
						</xsl:otherwise>
					</xsl:choose>
				</PriceDerivationRule>
				
				<ReasonCode>
					<xsl:value-of select="szDiscDesc"/>
				</ReasonCode>
				<xsl:if test="szGlobalCampaignID != ''">
					<WN:CampaignID>
						<xsl:value-of select="szGlobalCampaignID"/>
					</WN:CampaignID>
				</xsl:if>
				<WN:InternalTypeCode>
					<xsl:value-of select="lDiscListType"/>
				</WN:InternalTypeCode>
				<xsl:call-template name="CreateInfo">
					<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
				</xsl:call-template>
			</RetailPriceModifier>
		</xsl:for-each>
		<!-- Tax from Item (old) -->
		<xsl:if test="ARTICLE/lVatStdTaxID != 0 and dVatStdSale != 0">
			<Tax TaxType="VAT">
				<Amount>
					<xsl:call-template name="AbsNumber">
						<xsl:with-param name="number" select="format-number(dVatStdSale, '#0.##')"/>
					</xsl:call-template>
				</Amount>
				<xsl:variable name="VatStdTaxID">
					<xsl:value-of select="ARTICLE/lVatStdTaxID"/>
				</xsl:variable>
				<xsl:for-each select="following-sibling::VAT[sVatIndex = $VatStdTaxID and (not(lTaVatKind) or lTaVatKind = 0)]">
					<xsl:if test="dVatValue != 0">
						<Percent>
							<xsl:value-of select="dVatValue"/>
						</Percent>
					</xsl:if>
					<Reason>
						<xsl:value-of select="szVatDesc"/>
					</Reason>
				</xsl:for-each>
				<TaxRuleID>
					<xsl:value-of select="$VatStdTaxID"/>
				</TaxRuleID>
			</Tax>
		</xsl:if>
		<xsl:if test="ARTICLE/lVatExtTaxID != 0 and dVatExtSale != 0">
			<Tax TaxType="Sales">
				<Amount>
					<xsl:call-template name="AbsNumber">
						<xsl:with-param name="number" select="format-number(dVatExtSale, '#0.##')"/>
					</xsl:call-template>
				</Amount>
				<xsl:variable name="VatExtTaxID">
					<xsl:value-of select="ARTICLE/lVatExtTaxID"/>
				</xsl:variable>
				<xsl:for-each select="following-sibling::VAT[sVatIndex = $VatExtTaxID and lTaVatKind = 1]">
					<xsl:if test="dVatValue != 0">
						<Percent>
							<xsl:value-of select="dVatValue"/>
						</Percent>
					</xsl:if>
					<Reason>
						<xsl:value-of select="szVatDesc"/>
					</Reason>
				</xsl:for-each>
				<TaxRuleID>
					<xsl:value-of select="$VatExtTaxID"/>
				</TaxRuleID>
			</Tax>
		</xsl:if>
		<!-- Tax from Item (new) -->
		<xsl:for-each select="following-sibling::TAX_ART[Hdr/lTaRefToCreateNmbr=$TaCreateNmbr]">
			<Tax TaxType="VAT">
				<xsl:if test="TAX/lManualSequenceNumber">
					<SequenceNumber>
						<xsl:call-template name="AbsNumber">
							<xsl:with-param name="number" select="TAX/lManualSequenceNumber"/>
						</xsl:call-template>
					</SequenceNumber>
				</xsl:if>
				<TaxAuthority>
					<xsl:value-of select="TAX/szTaxAuthorityID"/>
				</TaxAuthority>
				<xsl:if test="dTotalSale != 0">
					<TaxableAmount>
						<xsl:attribute name="TaxIncludedInTaxableAmountFlag"><xsl:choose><xsl:when test="TAX/bTaxIncluded != 0"><xsl:text>true</xsl:text></xsl:when><xsl:otherwise><xsl:text>false</xsl:text></xsl:otherwise></xsl:choose></xsl:attribute>
						<xsl:call-template name="AbsNumber">
							<xsl:with-param name="number" select="dTotalSale"/>
						</xsl:call-template>
					</TaxableAmount>
				</xsl:if>
				<xsl:if test="TAX/dTaxablePercent != 0">
					<TaxablePercentage>
						<xsl:value-of select="TAX/dTaxablePercent"/>
					</TaxablePercentage>
				</xsl:if>
				<ExactAmount>
					<xsl:choose>
						<xsl:when test="bTaxFree != 0">
							<xsl:text>0</xsl:text>
						</xsl:when>
						<xsl:when test="dIncludedExactTaxValue">
							<xsl:call-template name="AbsNumber">
								<xsl:with-param name="number" select="format-number(dIncludedExactTaxValue, '#0.##')"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="dExcludedExactTaxValue">
							<xsl:call-template name="AbsNumber">
								<xsl:with-param name="number" select="format-number(dExcludedExactTaxValue, '#0.##')"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>0</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</ExactAmount>
				<!-- Add Tax 0.00 for ALDI -->
				<Amount>
					<xsl:choose>
						<xsl:when test="bTaxFree != 0">
							<xsl:text>0</xsl:text>
						</xsl:when>
						<xsl:when test="dIncludedTaxValue">
							<xsl:call-template name="AbsNumber">
								<xsl:with-param name="number" select="format-number(dIncludedTaxValue, '#0.##')"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="dExcludedTaxValue">
							<xsl:call-template name="AbsNumber">
								<xsl:with-param name="number" select="format-number(dExcludedTaxValue, '#0.##')"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>0</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</Amount>
				<!-- Add Tax 0.00 for ALDI -->
				<xsl:if test="TAX/dPercent != 0">
					<Percent>
						<xsl:value-of select="TAX/dPercent"/>
					</Percent>
				</xsl:if>
				<xsl:if test="bTaxFree != 0">
					<TaxExemption>
						<CustomerExemptionID>
							<xsl:if test="//TAX_EXEMPTION/szExemptionID">
								<xsl:value-of select="//TAX_EXEMPTION/szExemptionID"/>
							</xsl:if>
						</CustomerExemptionID>
						<ExemptTaxAmount>
							<xsl:choose>
								<xsl:when test="TAX/bTaxIncluded != 0 and dFreeIncludedExactTaxValue">
									<xsl:call-template name="AbsNumber">
										<xsl:with-param name="number" select="dFreeIncludedExactTaxValue"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="not(TAX/bTaxIncluded != 0) and dFreeExcludedExactTaxValue">
									<xsl:call-template name="AbsNumber">
										<xsl:with-param name="number" select="dFreeExcludedExactTaxValue"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</ExemptTaxAmount>
					</TaxExemption>
				</xsl:if>
				<xsl:if test="TAX/szTaxGroupRuleName != ''">
					<TaxRuleID>
						<xsl:value-of select="TAX/szTaxGroupRuleName"/>
					</TaxRuleID>
				</xsl:if>
				<xsl:if test="TAX/szTaxGroupID != ''">
					<TaxGroupID>
						<xsl:value-of select="TAX/szTaxGroupID"/>
					</TaxGroupID>
				</xsl:if>
			</Tax>
		</xsl:for-each>
		<!-- serial number? -->
		<xsl:for-each select="following-sibling::SERIALIZED[Hdr/lTaRefToCreateNmbr = $TaCreateNmbr]">
			<SerialNumber>
				<xsl:value-of select="szSerialNmbr"/>
			</SerialNumber>
		</xsl:for-each>
		<xsl:if test="lOrgTaNmbr != 0">
			<TransactionLink ReasonCode="Return">
				<RetailStoreID>
					<xsl:value-of select="lOrgRetailStoreID"/>
				</RetailStoreID>
				<WorkstationID>
					<xsl:value-of select="lOrgWorkstationNmbr"/>
				</WorkstationID>
				<SequenceNumber>
					<xsl:value-of select="lOrgTaNmbr"/>
				</SequenceNumber>
				<LineItemSequenceNumber>
					<xsl:value-of select="lOrgCreateNmbr"/>
				</LineItemSequenceNumber>
				<BeginDateTime>
					<xsl:call-template name="formatdatetime">
						<xsl:with-param name="datetime" select="szOrgDate"/>
					</xsl:call-template>
				</BeginDateTime>
			</TransactionLink>
		</xsl:if>
		<!-- Check if lineItem is null and if link is to Customer Order, then drop the item link -->
		<xsl:if test="($RefLineItem > 0) and not(./Hdr/szTaRefTaObject = 'CUSTOMER_ORDER')">
			<xsl:for-each select="//Hdr[lTaCreateNmbr = $RefLineItem]">
				<ItemLink>
					<xsl:value-of select="lTaSeqNmbr"/>
				</ItemLink>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="ARTICLE/bArtKVSet != 0 or ARTICLE/bArtVSet != 0">
			<Kit>
				<xsl:for-each select="following-sibling::ART_V_SET[Hdr/lTaRefToCreateNmbr = $TaCreateNmbr]">
					<Member Action="IsPartOf">
						<xsl:choose>
							<xsl:when test="$SaleOrReturn = 'Sale'">
								<Sale>
									<xsl:call-template name="returnsale">
										<xsl:with-param name="ItemTypeValue" select="$ItemTypeValue"/>
										<xsl:with-param name="TaCreateNmbr" select="Hdr/lTaCreateNmbr"/>
										<xsl:with-param name="RefLineItem" select="$TaCreateNmbr"/>
										<xsl:with-param name="SaleOrReturn" select="'Sale'"/>
										<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
									</xsl:call-template>
								</Sale>
							</xsl:when>
							<xsl:otherwise>
								<Return>
									<xsl:call-template name="returnsale">
										<xsl:with-param name="ItemTypeValue" select="$ItemTypeValue"/>
										<xsl:with-param name="TaCreateNmbr" select="Hdr/lTaCreateNmbr"/>
										<xsl:with-param name="RefLineItem" select="$TaCreateNmbr"/>
										<xsl:with-param name="SaleOrReturn" select="'Return'"/>
										<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
									</xsl:call-template>
								</Return>
							</xsl:otherwise>
						</xsl:choose>
					</Member>
				</xsl:for-each>
			</Kit>
		</xsl:if>
		<xsl:if test="$SaleOrReturn = 'Return' and $ItemTypeValue != 'WN:NegativeItem'">
			<Disposal>
				<xsl:attribute name="Method">ReturnToStock</xsl:attribute>
			</Disposal>
		</xsl:if>
		<xsl:if test="ARTICLE/lWarranty != 0">
			<WN:Warranty>
				<xsl:value-of select="ARTICLE/lWarranty"/>
			</WN:Warranty>
		</xsl:if>
		<xsl:if test="ARTICLE/szDescription != ''">
			<WN:AdditionalDesc>
				<xsl:value-of select="ARTICLE/szDescription"/>
			</WN:AdditionalDesc>
		</xsl:if>
		<xsl:if test="szInputString != '' and szInputString != szItemLookupCode">
			<WN:BarcodeTemplate>
				<xsl:value-of select="szInputString"/>
			</WN:BarcodeTemplate>
		</xsl:if>
		<xsl:if test="dTaBonusPoints != 0">
			<WN:BonusPoints>
				<xsl:value-of select="dTaBonusPoints"/>
			</WN:BonusPoints>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="dMeasurementEntry1 != 0 and dMeasurementEntry2 != 0 and dMeasurementEntry3 != 0">
				<WN:Measurement>
					<xsl:value-of select="concat(dMeasurementEntry1, 'x', dMeasurementEntry2, 'x', dMeasurementEntry3)"/>
				</WN:Measurement>
			</xsl:when>
			<xsl:when test="dMeasurementEntry1 != 0 and dMeasurementEntry2 != 0">
				<WN:Measurement>
					<xsl:value-of select="concat(dMeasurementEntry1, 'x', dMeasurementEntry2)"/>
				</WN:Measurement>
			</xsl:when>
			<xsl:when test="dMeasurementEntry1 != 0">
				<WN:Measurement>
					<xsl:value-of select="dMeasurementEntry1"/>
				</WN:Measurement>
			</xsl:when>
		</xsl:choose>
		<xsl:for-each select="preceding-sibling::SALESMEN[position()=1]">
			<!-- search for the possibly existing SALESMEN object -->
			<WN:EmployeeID>
				<xsl:if test="EMPLOYEE/szEmplName != ''">
					<xsl:attribute name="EmployeeName"><xsl:value-of select="EMPLOYEE/szEmplName"/></xsl:attribute>
				</xsl:if>
				<xsl:value-of select="EMPLOYEE/lEmployeeID"/>
			</WN:EmployeeID>
		</xsl:for-each>
		<xsl:for-each select="following-sibling::SPECIAL_CRITERIA[Hdr/lTaRefToCreateNmbr=$TaCreateNmbr]">
			<!-- special sorting criteria for this article -->
			<WN:SpecialCriteria>
				<GroupID>
					<xsl:value-of select="lSpecialCriteriaGroupID"/>
				</GroupID>
				<GroupName>
					<xsl:value-of select="szSpecialCriteriaGroupName"/>
				</GroupName>
				<CriteriaID>
					<xsl:value-of select="lSpecialCriteriaID"/>
				</CriteriaID>
				<CriteriaName>
					<xsl:value-of select="szSpecialCriteriaName"/>
				</CriteriaName>
			</WN:SpecialCriteria>
		</xsl:for-each>
		<xsl:for-each select="following-sibling::ADDON_DIALOG[Hdr/lTaRefToCreateNmbr=$TaCreateNmbr]">
			<!-- special addon dialog for this article -->
			<WN:AddonDialog>
				<xsl:if test="szAddOnDialog != ''">
					<Header>
						<xsl:value-of select="szAddOnDialog"/>
					</Header>
				</xsl:if>
				<xsl:if test="szAddOnText1 != ''">
					<Prompt1>
						<xsl:value-of select="szAddOnText1"/>
					</Prompt1>
				</xsl:if>
				<xsl:if test="szAddOnInput1 != ''">
					<Input1>
						<xsl:value-of select="szAddOnInput1"/>
					</Input1>
				</xsl:if>
				<xsl:if test="szAddOnText2 != ''">
					<Prompt2>
						<xsl:value-of select="szAddOnText2"/>
					</Prompt2>
				</xsl:if>
				<xsl:if test="szAddOnInput2 != ''">
					<Input2>
						<xsl:value-of select="szAddOnInput2"/>
					</Input2>
				</xsl:if>
				<xsl:if test="szAddOnText3 != ''">
					<Prompt3>
						<xsl:value-of select="szAddOnText3"/>
					</Prompt3>
				</xsl:if>
				<xsl:if test="szAddOnInput3 != ''">
					<Input3>
						<xsl:value-of select="szAddOnInput3"/>
					</Input3>
				</xsl:if>
				<xsl:if test="szAddOnText4 != ''">
					<Prompt4>
						<xsl:value-of select="szAddOnText4"/>
					</Prompt4>
				</xsl:if>
				<xsl:if test="szAddOnInput4 != ''">
					<Input4>
						<xsl:value-of select="szAddOnInput4"/>
					</Input4>
				</xsl:if>
			</WN:AddonDialog>
		</xsl:for-each>
		<WN:LocalStoreItem>
			<xsl:choose>
				<xsl:when test="ARTICLE/lProdRangeID=-1">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</WN:LocalStoreItem>
	</xsl:template>
	<!--*********************************************************************************************************-->
	<!--****************************               template: OrderedArticle           ****************************-->
	<xsl:template name="OrderedArticle">
		<xsl:param name="ItemTypeValue"/>
		<xsl:param name="TaCreateNmbr"/>
		<xsl:param name="RefLineItem"/>
		<xsl:param name="Alpha2Code"/>
		<xsl:attribute name="ItemType"><xsl:value-of select="$ItemTypeValue"/></xsl:attribute>
		<POSIdentity POSIDType="EAN">
			<POSItemID>
				<xsl:value-of select="szArticleNumber"/>
			</POSItemID>
		</POSIdentity>		
		<!-- Ordered_ARTICLE_Always Not In File -->
		<ItemNotOnFileFlag>true</ItemNotOnFileFlag>
		<Description>
			<xsl:value-of select="szDescription"/>
		</Description>
		<xsl:if test="ARTICLE/dPackingUnitPriceAmount != 0">
			<UnitListPrice>
				<xsl:call-template name="AbsNumber">
					<xsl:with-param name="number" select="dUnitPrice"/>
				</xsl:call-template>
			</UnitListPrice>
		</xsl:if>
		<RegularSalesUnitPrice>
			<xsl:call-template name="AbsNumber">
				<xsl:with-param name="number" select="dUnitPrice"/>
			</xsl:call-template>
		</RegularSalesUnitPrice>
		<ActualSalesUnitPrice>
			<xsl:call-template name="AbsNumber">
				<xsl:with-param name="number" select="0"/>
			</xsl:call-template>
		</ActualSalesUnitPrice>
		<ExtendedAmount>
			<xsl:call-template name="AbsNumber">
				<xsl:with-param name="number" select="0"/>
			</xsl:call-template>
		</ExtendedAmount>
		<Quantity>
			<xsl:choose>
				<xsl:when test="dQuantity">
					<xsl:call-template name="AbsNumber">
						<xsl:with-param name="number" select="dQuantity"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="AbsNumber">
						<xsl:with-param name="number" select="0"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</Quantity>
		<xsl:for-each select="preceding-sibling::SALESMEN[position()=1]">
			<!-- search for the possibly existing SALESMEN object -->
			<WN:EmployeeID>
				<xsl:if test="EMPLOYEE/szEmplName != ''">
					<xsl:attribute name="EmployeeName"><xsl:value-of select="EMPLOYEE/szEmplName"/></xsl:attribute>
				</xsl:if>
				<xsl:value-of select="EMPLOYEE/lEmployeeID"/>
			</WN:EmployeeID>
		</xsl:for-each>
		<!-- Get Information from CustomerOrder -->
		<InventoryReservationID>
			<xsl:value-of select="./../*/Hdr[lTaCreateNmbr=$RefLineItem]/../szDocumentNumber"/>
		</InventoryReservationID>
		<From>
			<xsl:value-of select="./../*/Hdr[lTaCreateNmbr=$RefLineItem]/../szShopNumber"/>
		</From>
	</xsl:template>
</xsl:stylesheet>
