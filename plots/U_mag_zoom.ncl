
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

dfilename = getenv("NCL_ARG_2")
cfilename = getenv("NCL_ARG_3")
filename = getenv("NCL_ARG_4")

dfile = addfile(dfilename + ".nc", "r")
cfile = addfile(cfilename, "r")

u = dfile->U(0,3,:,:)
v = dfile->V(0,3,:,:)
hsurf = cfile->HSURF(0,:,:)

pole = cfile->rotated_pole
pole_lon = pole@grid_north_pole_longitude
pole_lat = pole@grid_north_pole_latitude

lat2d = cfile->lat
lon2d = cfile->lon

; geo-reference data
u@lat2d = lat2d
u@lon2d = lon2d
u@long_name = ""
u@units      = ""
v@lat2d = lat2d
v@lon2d = lon2d
v@long_name = ""
v@units      = ""
hsurf@lat2d = lat2d
hsurf@lon2d = lon2d
hsurf@long_name = ""

; Compute Windspeed
u_mag = u
u_mag = sqrt(u^2+v^2)

;==============================================================

res                       = True
res@gsnDraw               = False
res@gsnFrame              = False
res@tiYAxisString         = ""
res@tiXAxisString         = ""
res@gsnMaximize           = True
res@gsnPaperOrientation   = "portrait"
res@gsnAddCyclic          = False

ures                      = res
tres                      = res

;Define the underlying map
;-------------------------
tres@mpProjection           = "Mercator"
tres@mpDataBaseVersion      = "HighRes"
tres@mpDataBaseVersion      = "Ncarg4_1"
tres@mpDataSetName          = "Earth..4"
tres@pmTickMarkDisplayMode  = "never"
tres@mpLabelsOn             = False
tres@mpOutlineOn            = True
tres@mpOutlineDrawOrder     = "PostDraw"
tres@mpGeophysicalLineThicknessF = 4

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

;Define contours
;----------------

res@cnFillOn                = True
res@cnFillMode              = "CellFill"
res@cnLinesOn               = False
res@cnFillOpacityF         = 0.7

res@cnInfoLabelOn          = False
res@cnLineLabelsOn         = False
res@gsnSpreadColors        = True

wks = gsn_open_wks("png", filename )
gsn_define_colormap(wks,"MPL_viridis")


res@cnLevelSelectionMode   = "ManualLevels"
res@cnMinLevelValF         = 1
res@cnMaxLevelValF         = 10
res@cnLevelSpacingF        = 1 

;Add wind vectors
;---------------------

ures@vcGlyphStyle              = "LineArrow"
ures@vcRefMagnitudeF           = 10.0
ures@vcRefLengthF              = 0.07
ures@vcLineArrowColor          = "white"
ures@vcFillArrowsOn            = True
ures@vcFillArrowFillColor      = "white"
ures@vcGlyphOpacityF           = 0.7
ures@vcMinDistanceF            = 0.04
ures@vcLineArrowThicknessF     = 5.0
ures@vcLineArrowHeadMinSizeF    = 0.004
ures@vcLineArrowHeadMaxSizeF    = 0.004

ures@vcRefAnnoArrowLineColor   = "black"
ures@vcRefAnnoArrowUseVecColor = False


;=============================================================
plot= gsn_csm_contour_map(wks,hsurf(:,:),tres)
plot_p= gsn_csm_contour(wks,u_mag(:,:),res)
plot_vec = gsn_csm_vector(wks, u, v, ures)
;============================================================

overlay(plot,plot_p)
overlay(plot,plot_vec)

draw(plot)
frame(wks)


end

