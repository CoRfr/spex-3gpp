// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.qtip
//= require jquery-ui
//= require_tree .

$(document).ready(function() {
    // $("span.timeago").timeago();

    $(".with-tooltip").each(
            function(index, elmt)
            {
                pos = {
                    at: 'bottom right',
                    my: 'top left'
                };
                
                if($(this).hasClass('with-tooltip-left')) {
                    pos = {
                        at: 'bottom left',
                        my: 'top right'
                    };
                }
                
                $(this).qtip(
                {
                    content: $(this).next(".assos-tooltip").html(),
                    position: pos,
                    style: {
                        classes: 'ui-tooltip-shadow ui-tooltip-light ui-tooltip-rounded'
                    }
                });
            }
        );

    $("#scopes h4.header").each(
        function(index, elmt)
        {
            title = $(elmt).children("a");
            elmt_content = $(elmt).next();
            
            $(title).removeAttr("href");
            
            if(!$(this).hasClass('expanded'))
            {
                $(elmt_content).fadeOut('fast');
                $(this).parent().addClass('collapsed')
            }
            
            $(title).data("child", elmt_content);
            $(title).click(function() {
                if(!$(this).parent().hasClass('expanded'))
                {
                    elmt = $(this).data("child");
                    $(elmt).fadeIn('fast');
                    $(this).parent().addClass('expanded');
                    $(this).parent().removeClass('collapsed');
                }
                else
                {
                    elmt = $(this).data("child");
                    $(elmt).fadeOut('fast');
                    $(this).parent().removeClass('expanded');
                    $(this).parent().addClass('collapsed');
                }        
            });
        }
    );
});
