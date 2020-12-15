
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

dfilename = getenv("NCL_ARG_2")
cfilename = getenv("NCL_ARG_3")
filename = getenv("NCL_ARG_4")

dfile = addfile(dfilename + ".nc", "r")
cfile = addfile(cfilename, "r")

p = dfile->TOT_PREC(0,:,:)
land_mask = cfile->FR_LAND(0,:,:)
hsurf = cfile->HSURF(0,:,:)

pole = cfile->rotated_pole
pole_lon = pole@grid_north_pole_longitude
pole_lat = pole@grid_north_pole_latitude

lat2d = cfile->lat
lon2d = cfile->lon

; geo-reference data
p@lat2d = lat2d
p@lon2d = lon2d
p@long_name = ""
p@units      = ""
hsurf@lat2d = lat2d
hsurf@lon2d = lon2d
hsurf@long_name = ""
hsurf@units      = ""

p = mask(p,land_mask.lt.0.5,False)
p = p * 24. ; convert to mm/day

;==============================================================

res                       = True
res@gsnDraw               = False
res@gsnFrame              = False
res@tiYAxisString         = ""
res@tiXAxisString         = ""
res@gsnMaximize           = True
res@gsnPaperOrientation   = "portrait"
res@gsnAddCyclic          = False

tres                      = res

;Define the underlying map
;-------------------------
tres@mpProjection           = "Mercator"
;tres@mpOutlineBoundarySets  = "National"
tres@mpDataBaseVersion      = "HighRes"
tres@mpDataBaseVersion      = "Ncarg4_1"
tres@mpDataSetName          = "Earth..4"
tres@pmTickMarkDisplayMode  = "never"
tres@mpLabelsOn             = False
tres@mpFillOn               = True
tres@mpOutlineOn            = True
tres@mpOutlineDrawOrder     = "PostDraw"
tres@mpFillDrawOrder        = "PreDraw"
tres@mpOceanFillColor       = "grey78"
tres@mpLandFillColor        = "white"

;Rotate pole
;-----------
tres@mpCenterLonF            = pole_lon + 180.
tres@mpCenterLatF            = 90. - pole_lat
;tres@tfDoNDCOverlay          = False

tres@mpLimitMode            = "Corners"
tres@mpLeftCornerLatF       = 41.5
tres@mpLeftCornerLonF       = 1
tres@mpRightCornerLatF      = 51
tres@mpRightCornerLonF      = 20


;;2km analysis domain
;tres@mpLimitMode            = "Corners"
;tres@mpLeftCornerLatF       = 41
;tres@mpLeftCornerLonF       = 2
;tres@mpRightCornerLatF      = 50
;tres@mpRightCornerLonF      = 22

;Define contours
;----------------

res@cnFillOn                = True
res@cnFillMode              = "CellFill"
res@cnLinesOn               = False

;res@lbLabelBarOn           = False
res@cnInfoLabelOn          = False
res@cnLineLabelsOn         = False
res@lbOrientation          = "vertical"
res@gsnSpreadColors        = True

wks = gsn_open_wks("png", filename )
;gsn_define_colormap(wks,"CBR_coldhot")
gsn_define_colormap(wks,"MPL_RdBu")
;gsn_reverse_colormap(wks) 
res@cnFillOpacityF 	   = 0.80

res@cnLevelSelectionMode   = "ManualLevels"
res@cnMinLevelValF         = -5
res@cnMaxLevelValF         = 5
res@cnLevelSpacingF        = 1 


; Topography
;-------------------
tres@cnInfoLabelOn          = False
tres@cnLineLabelsOn         = False

tres@cnLevelSelectionMode   = "ManualLevels"
tres@cnMinLevelValF         = 0
tres@cnMaxLevelValF         = 3500
tres@cnLevelSpacingF        = 1000 
tres@cnMonoLineColor        = True
tres@cnLineColors           = "black"
tres@cnLineThicknessF       = 3
tres@cnMonoLineThickness    = True

;=============================================================
plot= gsn_csm_contour_map(wks,hsurf(:,:),tres)
plot_p= gsn_csm_contour(wks,p(:,:),res)
;============================================================

overlay(plot,plot_p)

draw(plot)
frame(wks)


end

