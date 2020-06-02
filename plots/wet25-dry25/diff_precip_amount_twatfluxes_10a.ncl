
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

dfilename = getenv("NCL_ARG_2")
ffilename = getenv("NCL_ARG_3")
cfilename = getenv("NCL_ARG_4")
filename = getenv("NCL_ARG_5")

dfile = addfile(dfilename + ".nc", "r")
ffile = addfile(ffilename + ".nc", "r")
cfile = addfile(cfilename, "r")

p = dfile->TOT_PREC(0,:,:)
twu = ffile->TWATFLXU_A(0,:,:)
twv = ffile->TWATFLXV_A(0,:,:)
land_mask = cfile->FR_LAND(0,:,:)

; Spcial case for 10a run, because I was idiot
twu = -twu
twv = -twv

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
twu@lat2d = lat2d
twu@lon2d = lon2d
twu@long_name = ""
twu@units      = ""
twv@lat2d = lat2d
twv@lon2d = lon2d
twv@long_name = ""
twv@units      = ""

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

ures                      = res

;Define the underlying map
;-------------------------
res@mpProjection           = "Mercator"
res@mpOutlineBoundarySets  = "National"
res@mpDataBaseVersion      = "HighRes"
res@mpDataBaseVersion      = "Ncarg4_1"
res@mpDataSetName          = "Earth..4"
res@pmTickMarkDisplayMode  = "never"
res@mpLabelsOn             = False
res@mpFillOn               = True
res@mpOutlineOn            = True
res@mpOutlineDrawOrder     = "PostDraw"
res@mpFillDrawOrder        = "PreDraw"
res@mpOceanFillColor  = "grey78"

;Rotate pole
;-----------
res@mpCenterLonF            = pole_lon + 180.
res@mpCenterLatF            = 90. - pole_lat
;res@tfDoNDCOverlay          = False

;2km analysis domain
res@mpLimitMode            = "Corners"
res@mpLeftCornerLatF       = 32.1166
res@mpLeftCornerLonF       = -9.43726
res@mpRightCornerLatF      = 59.5612
res@mpRightCornerLonF      = 28.9279

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

res@cnLevelSelectionMode   = "ManualLevels"
res@cnMinLevelValF         = -5
res@cnMaxLevelValF         = 5
res@cnLevelSpacingF        = 1 

;Add wind vectors
;---------------------

ures@vcGlyphStyle              = "LineArrow"
;ures@vcGlyphStyle              = "CurlyVector"
ures@vcRefMagnitudeF           = 120.0
ures@vcRefLengthF              = 0.07
ures@vcLineArrowColor          = "black"
ures@vcFillArrowsOn            = True
ures@vcFillArrowFillColor      = "black"
ures@vcGlyphOpacityF           = 0.4
ures@vcMinDistanceF            = 0.04
ures@vcLineArrowThicknessF     = 5.0
ures@vcLineArrowHeadMinSizeF    = 0.004
ures@vcLineArrowHeadMaxSizeF    = 0.004

ures@vcRefAnnoArrowLineColor   = "black"
ures@vcRefAnnoArrowUseVecColor = False




;=============================================================
plot= gsn_csm_contour_map(wks,p(:,:),res)
plot_flx = gsn_csm_vector(wks, twu, twv, ures)
;============================================================

overlay(plot,plot_flx)

draw(plot)
frame(wks)


end

