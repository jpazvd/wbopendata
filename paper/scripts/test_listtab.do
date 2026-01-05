* Test listtab for LaTeX table output
* Roger Newson's listtab can output directly to LaTeX format

clear all
set more off

* Check if listtab is installed
cap which listtab
if _rc != 0 {
    di "Installing listtab..."
    ssc install listtab, replace
}

* Load data with full option
wbopendata, indicator(NY.GDP.MKTP.CD) country(BRA) clear full nometadata
keep in 1

* Option A: listtab with rstyle(tabular)
di _n "=== listtab with LaTeX tabular style ==="
listtab countrycode region regionname incomelevel incomelevelname, type ///
    rstyle(tabular) head("\begin{tabular}{lllll}" "\hline" ///
    "Code & Region & Region Name & Income & Income Name \\\\ \hline") ///
    foot("\hline" "\end{tabular}")

* Option B: listtab for attributes - vertical layout
di _n "=== listtab vertical layout ==="

* Create a transposed view for cleaner display
preserve
    clear
    input str20 attribute str40 value
    "Region Code" "LCN"
    "Region Name" "Latin America and Caribbean"
    "Income Code" "UMC"  
    "Income Name" "Upper middle income"
    "Admin Region" "LAC"
    "Admin Name" "LAC (excl. high income)"
    "Lending Type" "IBD"
    "Lending Name" "IBRD"
    "Capital" "Brasilia"
    "Latitude" "-15.7801"
    "Longitude" "-47.9292"
    end
    
    listtab attribute value, type rstyle(tabular) ///
        head("\begin{tabular}{ll}" "\hline" "Attribute & Value \\\\ \hline") ///
        foot("\hline" "\end{tabular}")
restore

di _n "Done!"
