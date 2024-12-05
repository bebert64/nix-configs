{
  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
      # Necessary for gmail oauth2 to work
      settings = {
        "calendar.list.sortOrder" = "stockly-romainc claire-romain bebert64 booba chamber-of-secrets asterix rick-morty michael-scott thiago-motta obelix dalida nam-nam britney pikachu";
        "calendar.registry.stockly-romainc.cache.enabled" = 10;
        "calendar.registry.stockly-romainc.calendar-main-default" = true;
        "calendar.registry.stockly-romainc.calendar-main-in-composite" = true;
        "calendar.registry.stockly-romainc.name" = "Stockly - RomainC";
        "calendar.registry.stockly-romainc.type" = "caldav";
        "calendar.registry.stockly-romainc.uri" = "https://apidata.googleusercontent.com/caldav/v2/romain%40stockly.ai/events/";
        "calendar.registry.stockly-romainc.username" = "romain@stockly.ai";

        "calendar.registry.claire-romain.name" = "Claire et Romain";
        "calendar.registry.claire-romain.cache.enabled" = 10;
        "calendar.registry.claire-romain.type" = "caldav";
        "calendar.registry.claire-romain.uri" = "https://apidata.googleusercontent.com/caldav/v2/6fa964788b489be996198104f497260a02036c6772d2879ae3336e7440518536%40group.calendar.google.com/events/";
        "calendar.registry.claire-romain.username" = "bebert64@gmail.com";

        "calendar.registry.bebert64.name" = "Bebert64";
        "calendar.registry.bebert64.cache.enabled" = 10;
        "calendar.registry.bebert64.type" = "caldav";
        "calendar.registry.bebert64.uri" = "https://apidata.googleusercontent.com/caldav/v2/bebert64%40gmail.com/events/";
        "calendar.registry.bebert64.username" = "bebert64@gmail.com";

        "calendar.registry.booba.cache.enabled" = 10;
        "calendar.registry.booba.name" = "Booba - 1st Right Right";
        "calendar.registry.booba.type" = "caldav";
        "calendar.registry.booba.uri" = "https://apidata.googleusercontent.com/caldav/v2/c_fc9heh7f219aqa5e4j6nrttr6k%40group.calendar.google.com/events/";
        "calendar.registry.booba.username" = "romain@stockly.ai";

        "calendar.registry.thiago-motta.cache.enabled" = 10;
        "calendar.registry.thiago-motta.name" = "Thiago Motta - RDC Open Space";
        "calendar.registry.thiago-motta.type" = "caldav";
        "calendar.registry.thiago-motta.uri" = "https://apidata.googleusercontent.com/caldav/v2/c_br8e358bgc3i63aqml5h8hhjc4%40group.calendar.google.com/events/";
        "calendar.registry.thiago-motta.username" = "romain@stockly.ai";

        "calendar.registry.rick-morty.cache.enabled" = 10;
        "calendar.registry.rick-morty.name" = "Rick & Morty - 1st Right";
        "calendar.registry.rick-morty.type" = "caldav";
        "calendar.registry.rick-morty.uri" = "https://apidata.googleusercontent.com/caldav/v2/c_61ka55k249gmfhi96i6qmcvu1g%40group.calendar.google.com/events/";
        "calendar.registry.rick-morty.username" = "romain@stockly.ai";

        "calendar.registry.obelix.cache.enabled" = 10;
        "calendar.registry.obelix.name" = "Obélix - 1st Right Center";
        "calendar.registry.obelix.type" = "caldav";
        "calendar.registry.obelix.uri" = "https://apidata.googleusercontent.com/caldav/v2/c_de2hg8d7m099m9t52dovrplfno%40group.calendar.google.com/events/";
        "calendar.registry.obelix.username" = "romain@stockly.ai";

        "calendar.registry.britney.cache.enabled" = 10;
        "calendar.registry.britney.name" = "Britney - 1st Right Left";
        "calendar.registry.britney.type" = "caldav";
        "calendar.registry.britney.uri" = "https://apidata.googleusercontent.com/caldav/v2/c_c6ahr4qn4ub2koopnqthta2sac%40group.calendar.google.com/events/";
        "calendar.registry.britney.username" = "romain@stockly.ai";

        "calendar.registry.dalida.cache.enabled" = 10;
        "calendar.registry.dalida.name" = "Dalida - RDC Center";
        "calendar.registry.dalida.type" = "caldav";
        "calendar.registry.dalida.uri" = "https://apidata.googleusercontent.com/caldav/v2/c_maj52a38qbrudkl3c65n35qj6k%40group.calendar.google.com/events/";
        "calendar.registry.dalida.username" = "romain@stockly.ai";

        "calendar.registry.chamber-of-secrets.cache.enabled" = 10;
        "calendar.registry.chamber-of-secrets.name" = "The Chamber of Secrets - 1st Left";
        "calendar.registry.chamber-of-secrets.type" = "caldav";
        "calendar.registry.chamber-of-secrets.uri" = "https://apidata.googleusercontent.com/caldav/v2/c_8li431i1osdn97us3hr82k43jc%40group.calendar.google.com/events/";
        "calendar.registry.chamber-of-secrets.username" = "romain@stockly.ai";

        "calendar.registry.pikachu.cache.enabled" = 10;
        "calendar.registry.pikachu.name" = "Pikachu - RDC";
        "calendar.registry.pikachu.type" = "caldav";
        "calendar.registry.pikachu.uri" = "https://apidata.googleusercontent.com/caldav/v2/c_ij34fiug0hal4ft5ndc1ug78nk%40group.calendar.google.com/events/";
        "calendar.registry.pikachu.username" = "romain@stockly.ai";

        "calendar.registry.asterix.cache.enabled" = 10;
        "calendar.registry.asterix.name" = "Astérix - 1st Right Right";
        "calendar.registry.asterix.type" = "caldav";
        "calendar.registry.asterix.uri" = "https://apidata.googleusercontent.com/caldav/v2/c_vjmva1ml8kld5gvhq7khheo3l0%40group.calendar.google.com/events/";
        "calendar.registry.asterix.username" = "romain@stockly.ai";

        "calendar.registry.michael-scott.cache.enabled" = 10;
        "calendar.registry.michael-scott.name" = "Michael Scott - RDC Left";
        "calendar.registry.michael-scott.type" = "caldav";
        "calendar.registry.michael-scott.uri" = "https://apidata.googleusercontent.com/caldav/v2/c_35vu8jq07min1lig1ugn3kevks%40group.calendar.google.com/events/";
        "calendar.registry.michael-scott.username" = "romain@stockly.ai";

        "calendar.registry.nam-nam.cache.enabled" = 10;
        "calendar.registry.nam-nam.name" = "Nam Nam - RDC Right";
        "calendar.registry.nam-nam.type" = "caldav";
        "calendar.registry.nam-nam.uri" = "https://apidata.googleusercontent.com/caldav/v2/c_mo4fndl16t6dh9sj4e867rsldo%40group.calendar.google.com/events/";
        "calendar.registry.nam-nam.username" = "romain@stockly.ai";
      };
    };
  };
}
