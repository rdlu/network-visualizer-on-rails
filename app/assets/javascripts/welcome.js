/**
 * Created with JetBrains RubyMine.
 * User: saymon
 * Date: 17/01/13
 * Time: 11:01
 * To change this template use File | Settings | File Templates.
 */

//= require gmap/gmap3.js


$(function(){
    $("#googleMap").gmap3({
        map:{
            options: {
                center:[-14.904325,-48.209743],
                zoom: 4,
                zoomControl: true,
                zoomControlOptions: {
                    style: google.maps.ZoomControlStyle.LARGE
                },
                panControl: true,
                mapTypeId: google.maps.MapTypeId.TERRAIN,
                mapTypeControl: true,
                mapTypeControlOptions: {
                    style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
                },
                navigationControl: false,
                scrollwheel: true,
                streetViewControl: false
            }
        },
        marker: {
           values:[
                {latLng: [-22.904325,-43.209743], tag:"green"},
                {latLng: [-30.03306,-51.23], tag:"green"},
                [-22.904325,-45.209743],
                ],

            cluster:{
                radius:25,
                // This style will be used for clusters with more than 0 markers
                0: {
                    content: "<div class='cluster cluster-1'>CLUSTER_COUNT</div>",
                    width: 53,
                    height: 52
                },
                // This style will be used for clusters with more than 20 markers
                20: {
                    content: "<div class='cluster cluster-2'>CLUSTER_COUNT</div>",
                    width: 56,
                    height: 55
                },
                // This style will be used for clusters with more than 50 markers
                50: {
                    content: "<div class='cluster cluster-3'>CLUSTER_COUNT</div>",
                    width: 66,
                    height: 65
                }
            },
            options: {
                icon: new google.maps.MarkerImage("http://maps.gstatic.com/mapfiles/icon_green.png")
            },
            events:{
                mouseover: function(marker, event, context){
                    $(this).gmap3(
                        {clear:"overlay"},
                        {
                            overlay:{
                                latLng: marker.getPosition()

                            }
                        });
                },
                mouseout: function(){
                    $(this).gmap3({clear:"overlay"});
                }
            }

        }
    });
});
