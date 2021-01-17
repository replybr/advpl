#include "totvs.ch"
#include "fwmvcdef.ch"
 
PUBLISH MODEL REST NAME Branch RESOURCE OBJECT oRestBranch
 
Class oRestBranch From FwRestModel
Data lSm0Closed
 
Method Activate()
Method DeActivate()
Method Total()
Method SetAlias()
Method Skip()
Method Seek()
EndClass
 
Method Activate() Class oRestBranch
local lRet as logical
 
If _Super:Activate()
//Por uma regra de negócio, essa API não pode ser acessada aos domingos
If Dow( Date() ) == 1
//Atribuir .F. a propriedade self:lActivate
self:lActivate := .F.
 
//Retornar .F. no método
lRet := .F.
 
//( Opcional ) setar a mensagem
SetRestFault(403, "Forbidden access in sundays.")
 
Else
self:lSm0Closed := .F.
If Select("SM0") == 0
self:lSm0Closed := .T.
OpenSm0(, .F.)
EndIf
EndIf
 
Else
lRet := .F.
 
EndIf
 
Return lRet
 
Method DeActivate() Class oRestBranch
Local lRet as logical
 
If ( lRet := _Super:DeActivate() )
If self:lSm0Closed
SM0->(dbCloseArea())
EndIf
EndIf
 
Return lRet
 
Method Total() Class oRestBranch
Local nRecno as numeric
Local nTotal as numeric
 
nRecno := SM0->(Recno())
nTotal := 0
 
If self:Seek()
While !SM0->(Eof())
nTotal++
self:Skip()
End
EndIf
SM0->(dbGoTo(nRecno))
Return nTotal
 
Method SetAlias() Class oRestBranch
self:cAlias := "SM0"
Return .T.
 
Method Skip(nSkip) Class oRestBranch
Local lRet as logical
 
lRet := .F.
 
SM0->(DbSkip(nSkip))
lRet := !SM0->(Eof())
 
Return lRet
 
Method Seek(cPk) Class oRestBranch
Local lRet as logical
 
lRet := .F.
 
If Empty(cPK)
SM0->(DbGotop())
lRet := !SM0->(Eof())
Else
cPK := SubStr(cPK, Len(xFilial("SM0")) + 1) // Removo o valor da filial que e inserido automaticamente pelo model no valor da PK.
SM0->(dbSetOrder(1))
lRet := SM0->(DbSeek(cPK))
Endif
 
Return lRet
 
// MODELO DE DADOS
 
Static Function Modeldef()
Local oStruSM0 as object
Local oModel as object
 
oStruSM0 := DefStrModel()
oModel := FWFormModel():New( 'MYFILIAL',
{|| }, {|| }
 
,
{|| }, {|| }
 
)
 
oModel:AddFields( 'SM0MASTER', , oStruSM0,
{|| }, {|| }
 
,
{|oM| MyLoad() }
 
)
oModel:SetDescription( "Empresas Protheus" )
oModel:GetModel( 'SM0MASTER' ):SetDescription( "Empresas Protheus" )
oModel:SetPrimaryKey(
{"M0_CODIGO", "M0_CODFIL"}
 
)
Return oModel
 
Static Function DefStrModel()
Local oStruct as object
Local bValid as codeblock
Local bWhen as codeblock
Local bRelac as codeblock
 
oStruct := FWFormModelStruct():New()
bValid :=
{ || .T.}
 
bWhen :=
{ || }
bRelac := { || }
 
// TABELA
oStruct:AddTable( "SM0", {}, "Filiais",
{|| }
 
)
 
// INDICES
oStruct:AddIndex(1, "1", "M0_CODIGO", "Cód Empresa", "", "", .T.)
 
// CAMPOS
oStruct:AddField( "Cód Empresa" , "Cód Empresa" , "M0_CODIGO" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
oStruct:AddField( "Cód Filial" , "Cód Filial" , "M0_CODFIL" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
oStruct:AddField( "Nome Empresa" , "Nome Empresa" , "M0_NOMECOM", "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
oStruct:AddField( "CNPJ" , "CNPJ" , "M0_CGC" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
oStruct:AddField( "UF" , "UF" , "M0_ESTENT" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
oStruct:AddField( "Insc Estadual" , "Insc Estadual" , "M0_INSC" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
oStruct:AddField( "Insc Municipal", "Insc Municipal" , "M0_INSCM" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
oStruct:AddField( "Cód Munic" , "Cód Munic" , "M0_CODMUN" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
oStruct:AddField( "Nome Filial" , "Nome Filial" , "M0_FILIAL" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
oStruct:AddField( "Município" , "Município" , "M0_CIDENT" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
oStruct:AddField( "Inscrição" , "Inscrição" , "M0_INSCANT", "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
oStruct:AddField( "NIRE" , "NIRE" , "M0_NIRE" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
oStruct:AddField( "Data do Nire" , "Data do Nire" , "M0_DTRE" , "D", 08, 0, bValid, bWhen, , , bRelac, .F., , , )
oStruct:AddField( "End Cob" , "End Cob" , "M0_ENDCOB" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
 
Return oStruct
 
Static Function MyLoad()
Local aRet := {}
aRet := {{SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOMECOM, SM0->M0_CGC, SM0->M0_ESTENT, SM0->M0_INSC, SM0->M0_INSCM, SM0->M0_CODMUN,;
SM0->M0_FILIAL, SM0->M0_CIDENT, SM0->M0_INSCANT, SM0->M0_NIRE, SM0->M0_DTRE, SM0->M0_ENDCOB}, ;
SM0->(Recno())}
Return aRet