$(document).ready(function() {
    // Update the game page with the relevant content
    $("#game_map").load("/game/map");
    $("#game_inventory").load("/game/inventory");
    $("#game_description").load("/game/description");
    $("#game_messages").load("/game/messages");
});
