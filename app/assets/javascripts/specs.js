
function update_page_nb(page_nb) {

    // console.debug("update_page_nb " + page_nb + " (actual => " + current_page() + ")");

    if( current_page() != parseInt(page_nb)) {
        $("#page_jump").val(page_nb);
    }
}

function show_page(page_nb) {
    // console.debug("show_page " + page_nb);
    if(!is_page_visible(page_nb)) {
        update_page_nb(page_nb);

        current_offset = $("#pdf-main").scrollTop();
        next_offset = $("#p" + parseInt(page_nb).toString(16)).parent().offset().top;
        // console.debug("scroll to " + current_offset + " " + next_offset);
        $("#pdf-main").scrollTop(current_offset + next_offset - 50);
    }
}

function is_page_visible(page_nb) {
    if( $("#p" + parseInt(page_nb).toString(16)).length == 0)
        return false

    page_top = $("#p" + parseInt(page_nb).toString(16)).offset().top;
    page_height = $("#p" + parseInt(page_nb).toString(16)).height();
    page_bottom = page_top + page_height;

    win_height = $("#pdf-main").height();

    // console.debug(":" + page_nb + " " + page_top + " " + page_bottom + " " + win_height);

    if( (page_bottom < 0) || (page_top > win_height) )
        return false

    return true
}

function current_page() {
    return parseInt($("#page_jump").val());
}

function is_current_page_visible() {
    return is_page_visible(current_page());
}

$(document).ready(function() {

    $("#pdf-main").css("background","none");

    $("#page_toc").change(function() {
        show_page( $(this).val() );
    });

    $("#page_jump").change( function() {
        console.debug("page_jump changed => ");// + page_change_in_progress);
        show_page( $(this).val() );
    });

    $("#pdf-main").scroll(function() {
        // console.debug("Current: " + is_current_page_visible());

        if(true) {//!is_current_page_visible()) {
            nb_pages = parseInt($("#page_count").text());
            for(var i = 1; i < nb_pages; i++) {
                // console.debug(i + ":" + is_page_visible(i));
                if(is_page_visible(i)) {
                    update_page_nb(i);
                    break;
                }
            }
        }
    });
});