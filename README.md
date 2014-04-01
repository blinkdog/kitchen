# kitchen
A module to bake files from recipe files.

## kitchen
The kitchen executable provides the interface for baking files from
recipes. The subsections below document the subcommands recognized
by kitchen and the purpose/function of those commands.

### add
Add something to the kitchen. Such as a local or remote pantry to
look up and obtain ingredients, or an ingredient to a local pantry.

#### add ingredient [ingredient file]
Add an ingredient file to the local pantry.

Options:

    --kitchen /path/to/kitchen/directory

        Default: ${HOME}/.kitchen

#### add pantry [local/remote pantry]
Add a local or remote pantry to look up and obtain ingredients.

### bake [recipe]
Create a file from a recipe file. See the Recipe section below, for
more information on the recipe file format.

Options:

    --kitchen /path/to/kitchen/directory

        Default: ${HOME}/.kitchen

### help [subcommand]
Obtain help documentation on the provided subcommand.

### init
Initialize a .kitchen configuration and local pantry. The default
directory is: ${HOME}/.kitchen

## Recipe
A recipe file is a [JSON](http://json.org/) file containing recipe data
fields. A recipe file may end with the extension '.recipe.json' but this
is not required.

### name (REQUIRED)
The simple name of the file created by the recipe. The name field must
contain at least one valid character. The name field must not contain
any path specifiers, relative or absolute. Names containing path
specifiers should not be processed at all, for security reasons. 

    {
      "name": "1342.txt"
    }

### length (REQUIRED)
The length of the file to be baked. This should be a non-negative integer
value. 

    {
      "length": 717597
    }

### hash (RECOMMENDED)
The hash values to verify that the file has been baked correctly from
the recipe file.

    {
      "hash": {
        "ripemd160": "5aac0a87d3d54edd08326a73a045edc56805b33c",
        "sha512": "9ca5152a673dae24958c697aa26fe770caaef2e814eb94bdc6062c7fedbc51006a0b19a3756b9f11a4d78090ae7605217b6cd7510588bdc12b4d83d1dcaf4deb",
        "whirlpool": "c4ce1ad82ea158c6ddca77fcb9c8fa853ea94efc70436408b791e4aaf35c315ab9fd67b1cf42211953b8b43fcdd33fcf417f57a01af0d0e4928cf1bb2e626881"
      }
    }

The keys are the names of the algorithms provided by OpenSSL. The values
are the hash values computed from the content of the file. This section
is optional, but it is ***strongly*** recommended that it be provided with
every recipe. It is also recommended that multiple hash values from
different families of hash algorithm be provided.

### version (REQUIRED)
A tag to indicate the recipe format version being used by this recipe.
The current "official" version of the recipe format is 1.

    {
      "version": 1
    }

This field is metadata to assist kitchen. It helps to bake older recipes
according to the same process used for older files. It also helps to
identify newer recipes that an older version of kitchen might not be
able to bake correctly.

This field is a positive integer, starting at 1, incremented as the format
of recipe files are changed. The value 0 has a special meaning.

If your fork or implementation of kitchen uses recipe files that differ
significantly from the standard recipe format, you should not increment
the version number. Instead, specify a version of 0 and provide a vendor
field that includes version information specific to your implementation.

    {
      "version": 0,
      "vendor": {
        "1a31934e-62f9-4ab5-b140-06931ded2482": { ... }
      }
    }

See the vendor section below.

### vendor (OPTIONAL)
A field to contain vendor specific information about a recipe file.

Each vendor who forks or implements kitchen should generate a
random (Version 4) [UUID](https://en.wikipedia.org/wiki/UUID) for themselves.
This random UUID should be used in recipes to contain information specific to
that vendor's implementation.

    {
      "version": 1,
      "vendor": {
        "206834f6-4891-46af-8878-23660df7c1a2": {
          "os": "win64"
        }
      }
    }

If a vendor's implementation of kitchen uses recipe files that differ
significantly from the standard recipe format, specify a version of 0.

    {
      "version": 0,
      "vendor": {
        "1a31934e-62f9-4ab5-b140-06931ded2482": { ... }
      }
    }

When using a standard version number (>= 1), the vendor section is intended
to be advisory. The data contained in the section should be regarded as
additional information, annotations, or comments. This information may be
useful to some users, but may be disregarded by others without significant
loss of functionality.

When using a version number of 0, the vendor section is intended to be
**governing**. It indicates that may not be possible to make any sense of
the recipe file without use of the information contained in the vendor
section. Users who disregard this section may incur a significant loss
of functionality with respect to this recipe file.

Note that the vendor section can also be used for littering.

    {
      "version": 1,
      "vendor": {
        "d689a8b1-9944-4ae4-8402-b232dfa1c3bb": {
          "processor": "Macrohard Internets Deplorer 13"
        },
        "9d1a749e-bd01-47d3-b2b5-d89d40882a10": {
          "comment": "Patrick loves Mary."
        },
        "a67cb278-d225-4eca-a887-799aabfbe316": {
          "lolcatz": "wa suupa kawaii desu!"
        }
      }
    }

Think critically about the information that you provide to your
intended audience. Please don't litter.

### ingredients (REQUIRED)
The ingredients necessary to bake the file. This is a simply an array
of nameless ingredient objects, ordering is unimportant.

    {
      "ingredients": [
        { ... },
        { ... },
        { ... }
      ]
    }

This is typically the "meat" of the recipe file. Most of the recipe
consists of what goes into the file and how. The next subsections describe
the fields of the ingredient objects expected in the array.

#### hash (REQUIRED)
Identifies the ingredient data to be used in baking the file.

    {
      "ingredients": [
        {
          "hash": {
            "ripemd160": "69316edbab67d81d6f473d2bff7fcc1c2b9fec7c",
            "sha512": "dd9d4f62aebfdbc415fedbc934f6b51d78ab36c21230b6650bc0327bf79150aaded1487305f8a84ae0767175348b14216d53e1f72c2c56ee96e081576ca2406a",
            "whirlpool": "ef0ec5a06a10112e364bf079381672c941a97a1cee9d54f41223f3814999654cba67ebb16f8aeac243451a603a8a71125456b0fdbc5af9d6e8ca00ee2e3c8cb8"
          }
        }
      ]
    }

It is recommended that multiple hash values from different families of
hash algorithm be provided.

#### offset (REQUIRED)
Identifies the position of the ingredient when baking the file. This
is an integer, negative or positive.

    {
      "ingredients": [
        {
          "offset": 32764
        }
      ]
    }

Negative values less than the length of the ingredient, or positive
values greater than the length of the file are valid, but nonsense.
Nonsense ingredients should be ignored when baking the file.

    {
      "ingredients": [
        {
          "offset": -4294967295
        }
      ]
    }

#### mask (OPTIONAL)
A byte mask to be pre-XOR'd against each byte of the ingredient before
it is baked into the file. If it is used, valid values are 0 to 255.
If the value is not specified, it should be assumed to be 0. Invalid
values (<0 or >255) should also be assumed to be 0.

    {
      "ingredients": [
        {
          "mask": 234
        }
      ]
    }

This is an optional field intended to provide additional complexity
against file discovery attacks.

#### length (RECOMMENDED)
An advisory field, indicating the length of the ingredient binary in
bytes. Valid values are non-negative integers. A value of 0 is valid
but nonsense. Nonsense ingredients should be ignored when baking files.

    {
      "ingredients": [
        {
          "length": 478515
        }
      ]
    }

This field is optional, but it recommended that it be provided. It
provides a great help to clients that want to estimate the storage
and bandwidth requirements necessary to transfer and store the
ingredients for the recipe.

### fsm (JOKE)
If ye be a Pastafarian, be tellin' us by recognizin' His Noodly Appendage
in ye recipe!

    {
      "fsm": "http://www.venganza.org/"
    }

The field should contain the current URI of the Church of the Flying Spaghetti
Monster, whatever it happens to be at the time of the creation of the recipe.
Do your part to help in the fight against global climate change.

## Copyright
Copyright 2014 Patrick Meade.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
