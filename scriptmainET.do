*-----------------------------------------------------------
*DETERMINANTE DIGITALIZACION Y TRASICION ENERGETICA
*------------------------------------------------------------
*Jennifer Espinoza Soto (JLES)

clear all
import excel "DETER RENO.xls", sheet("DATA") firstrow

*Convertir REGION de string a numérico
encode REGION, gen(RREGION)

*creacion de nuevas variables
gen PERpc = (PER/PET)*100
gen PBIp = PBI/POB
gen DENPOB = POB/TERR 
gen AMIN = PMIN/PBI


*-----------------------------------------	
* ESTADISTICOS DECRIPTIVOS
*-----------------------------------------
summarize PET PERpc PBIp DENPOB IBFR DESM EDU INTER AMIN CREPR EXP IGAM
*if RREGION == "LIMA"

*-----------------------------------------
*Graficos estadisticos de las variables
*-----------------------------------------
graph twoway (lfit PERpc YEAR) (scatter PERpc YEAR ), ytitle(produccion renovable) xtitle(year) by(RREGION, legend(off) yrescale xrescale)
graph twoway (lfit PBIp YEAR) (scatter PBIp YEAR ), ytitle(PBI per capita ) xtitle(year) by(RREGION, legend(off) yrescale xrescale)

*-----------------------------------------
* Test de Correlacion
*-----------------------------------------
corr PERpc PBIp DENPOB IBFR EXP DESM EDU INTER AMIN IGAM 

*------------------------------------------
* MODELO DE REGRESION SIMPLE OLS
*------------------------------------------
*M1
reg PERpc PBIp IBFR DESM INTER AMIN IGAM DENPOB EDU CREPR EXP
dis "Adjusted Rsquared = " e(r2_a)
 
*M2
reg PERpc PBIp IBFR DESM INTER AMIN IGAM
dis "Adjusted Rsquared = " e(r2_a)


*-----------------------------------------
* MODELO DE EFECTOS FIJOS INDIVIDUALES
*-----------------------------------------
*Se define la unidad y tiempo
xtset RREGION YEAR 
sort RREGION YEAR 
*--------------------
*xtreg y x1 x2 x3, i(id) fe
*M1
xtreg PERpc PBIp IBFR DESM INTER AMIN IGAM DENPOB EDU CREPR EXP, fe 
dis "Adjusted Rsquared = " e(r2_a)

*M2
xtreg PERpc PBIp IBFR DESM INTER AMIN IGAM, fe 
dis "Adjusted Rsquared = " e(r2_a)

// Calcular los VIFs 
*vif, uncentered

quiet xtreg PERpc PBIp IBFR DESM INTER AMIN IGAM, fe 
estimates store MODFE

*-----------------------------------------
* MODELO DE EFECTOS FIJOS TEMPORALES
*-----------------------------------------
* Dummys por año 
gen y11=(YEAR==2011)
gen y12=(YEAR==2012)
gen y13=(YEAR==2013)
gen y14=(YEAR==2014)
gen y15=(YEAR==2015)
gen y16=(YEAR==2016)
gen y17=(YEAR==2017)
gen y18=(YEAR==2018)
gen y19=(YEAR==2019)
gen y20=(YEAR==2020)
gen y21=(YEAR==2021)
gen y22=(YEAR==2022)

*-------------------------------------------
*M1
xtreg PERpc PBIp IBFR DESM INTER AMIN IGAM DENPOB EDU CREPR EXP y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22, fe 
dis "Adjusted Rsquared = " e(r2_a)
*M2
xtreg PERpc PBIp IBFR DESM INTER AMIN IGAM y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22, fe 
dis "Adjusted Rsquared = " e(r2_a)

vif, uncentered
testparm y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22

quiet xtreg PERpc PBIp IBFR DESM INTER AMIN IGAM y11 y12 y13 y14 y15 y16 y17 y18 y19 y20 y21 y22, fe
estimates store MODFET

*-----------------------------------------
* MODELO DE EFECTOS ALEATORIOS
*-----------------------------------------
*M1
xtreg PERpc PBIp IBFR DESM INTER AMIN IGAM DENPOB EDU CREPR EXP, re 
dis "Adjusted Rsquared = " e(r2_a)
*M2
xtreg PERpc PBIp IBFR DESM INTER AMIN IGAM, re 
dis "Adjusted Rsquared = " e(r2_a)

*vif, uncentered

quiet xtreg PERpc PBIp IBFR DESM INTER AMIN IGAM, re
estimates store MODRE

*----------------------------------------------
* Prueba de Hausman 
*----------------------------------------------
hausman MODFET MODRE
hausman MODFE MODRE

* RESULTADO: el MODFET  es mas efectivo usar ya que no se rechaza la H0 a nivel de significancia del 5% 


