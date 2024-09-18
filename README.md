# sh_cmd_argv_sorter

## Space separate field sorter

* Example key field lines in ./example/pet
    ```
    name=Alice age=25 gender=female country=US has_pet=true animal=dog
    name=Bob age=40 gender=male country=UK has_pet=true animal=bird
    name=Carol age=28 gender=female country=JP has_pet=true animal=cat
    name=David age=35 gender=male country=AU has_pet=false animal=none
    name=Eve age=22 gender=female country=US has_pet=true animal=fish
    name=Frank age=45 gender=male country=AU has_pet=true animal=dog
    name=Grace age=32 gender=female country=UK has_pet=true animal=bird
    name=Hank age=38 gender=male country=JP has_pet=false animal=none
    name=Ivy age=29 gender=female country=US has_pet=true animal=cat
    name=Jack age=50 gender=male country=AU has_pet=false animal=none
    ```

* To Sort by "age":
    ```
    $ . cmd_argv_sorter.sh example/pet age
    ```
    * output:
    ```
    -age=22:
            name=Eve gender=female country=US has_pet=true animal=fish
    -age=25:
            name=Alice gender=female country=US has_pet=true animal=dog
    -age=28:
            name=Carol gender=female country=JP has_pet=true animal=cat
    -age=29:
            name=Ivy gender=female country=US has_pet=true animal=cat
    -age=32:
            name=Grace gender=female country=UK has_pet=true animal=bird
    -age=35:
            name=David gender=male country=AU has_pet=false animal=none
    -age=38:
            name=Hank gender=male country=JP has_pet=false animal=none
    -age=40:
            name=Bob gender=male country=UK has_pet=true animal=bird
    -age=45:
            name=Frank gender=male country=AU has_pet=true animal=dog

    ```

* To sort by "country":
    ```
    $ . cmd_argv_sorter.sh example/pet country
    ```
    * output:
    ```
    -country=AU:
            name=David age=35 gender=male has_pet=false animal=none
            name=Frank age=45 gender=male has_pet=true animal=dog
    -country=JP:
            name=Carol age=28 gender=female has_pet=true animal=cat
            name=Hank age=38 gender=male has_pet=false animal=none
    -country=UK:
            name=Bob age=40 gender=male has_pet=true animal=bird
            name=Grace age=32 gender=female has_pet=true animal=bird
    -country=US:
            name=Alice age=25 gender=female has_pet=true animal=dog
            name=Eve age=22 gender=female has_pet=true animal=fish
            name=Ivy age=29 gender=female has_pet=true animal=cat
    ```

* To Sort by "country" then "has_pet":
    ```
    $ . cmd_argv_sorter.sh example/pet country has_pet
    ```
    * output:
    ```
    -country=AU:
            -has_pet=false:
                    name=David age=35 gender=male animal=none
            -has_pet=true:
                    name=Frank age=45 gender=male animal=dog
    -country=JP:
            -has_pet=false:
                    name=Hank age=38 gender=male animal=none
            -has_pet=true:
                    name=Carol age=28 gender=female animal=cat
    -country=UK:
            -has_pet=true:
                    name=Bob age=40 gender=male animal=bird
                    name=Grace age=32 gender=female animal=bird
    -country=US:
            -has_pet=true:
                    name=Alice age=25 gender=female animal=dog
                    name=Eve age=22 gender=female animal=fish
                    name=Ivy age=29 gender=female animal=cat
    ```

* To Sort by "country", "has_pet" then "gender":
    ```
    $ . cmd_argv_sorter.sh example/pet country has_pet gender
    ```
    * output:
    ```
    -country=AU:
            -has_pet=false:
                    -gender=male:
                            name=David age=35 animal=none
            -has_pet=true:
                    -gender=male:
                            name=Frank age=45 animal=dog
    -country=JP:
            -has_pet=false:
                    -gender=male:
                            name=Hank age=38 animal=none
            -has_pet=true:
                    -gender=female:
                            name=Carol age=28 animal=cat
    -country=UK:
            -has_pet=true:
                    -gender=female:
                            name=Grace age=32 animal=bird
                    -gender=male:
                            name=Bob age=40 animal=bird
    -country=US:
            -has_pet=true:
                    -gender=female:
                            name=Alice age=25 animal=dog
                            name=Eve age=22 animal=fish
                            name=Ivy age=29 animal=cat
    ```

* To Sort by "country", "has_pet", "gender" then "animal":
    ```
    $ . cmd_argv_sorter.sh example/pet country has_pet gender animal
    ```
    * output:
    ```
    -country=AU:
            -has_pet=false:
                    -gender=male:
                            -animal=none:
                                    name=David age=35
            -has_pet=true:
                    -gender=male:
                            -animal=dog:
                                    name=Frank age=45
    -country=JP:
            -has_pet=false:
                    -gender=male:
                            -animal=none:
                                    name=Hank age=38
            -has_pet=true:
                    -gender=female:
                            -animal=cat:
                                    name=Carol age=28
    -country=UK:
            -has_pet=true:
                    -gender=female:
                            -animal=bird:
                                    name=Grace age=32
                    -gender=male:
                            -animal=bird:
                                    name=Bob age=40
    -country=US:
            -has_pet=true:
                    -gender=female:
                            -animal=cat:
                                    name=Ivy age=29
                            -animal=dog:
                                    name=Alice age=25
                            -animal=fish:
                                    name=Eve age=22
    ```
