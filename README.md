<p align="center">
  <h3 align="center">
    transmog
  </h3>

  <p align="center">
    Easily perform deep in-place data mappings for keys on lists and maps.
  </p>
</p>

## Table Of Contents

- [Table Of Contents](#table-of-contents)
- [About](#about)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgements](#acknowledgements)

## About

`transmog` is a simple module which allows for in-place data mapping for keys
on deeply nested lists and maps. One use case for this library is to convert
external data into a shape that is compatible with an internal data structure.

## Installation

To install `transmog` add the following to your `mix.exs` file and run
`mix deps.get` in your project root directory.

```elixir
defp deps do
  [{:transmog, "~> 0.1.0"}]
end
```

## Getting Started

The simplest way to use `transmog` is to first create a key mapping for your
data

```elixir
defmodule TransmogExample do
  @key_mapping [
    {"account", ":user"},
    {"account.identity", ":user.:details"},
    {"account.identity.first_name", ":user.:details.:first_name}
  ]
end
```

This key mapping says that the `account` key in a map or list of maps will be
converted to `:user`, `identity` to `:details`, and `first_name` to
`:first_name`. The entire chain does not have to be present if you only want
to update the lowest level.

Once you have a key mapping defined you can then perform the mapping using
`Transmog.format/2`

```elixir
iex> fields = %{"account" => %{"identity" => %{"first_name" => "Billy"}}}
iex> Transmog.format(fields, @key_mapping)
%{user: %{details: %{first_name: "Bobby"}}}
```

## Contributing

I would greatly appreciate any contributions to make this project better. Please
make sure to follow the below guidelines before getting your hands dirty.

1. Fork the repository
2. Create your branch (`git checkout -b my-branch`)
3. Commit any changes to your branch
4. Push your changes to your remote branch
5. Open a pull request

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Acknowledgements

- [elixir](https://elixir-lang.org/)

Copyright &copy; 2019 Dylan Aspden
