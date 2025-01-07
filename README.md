# UkraineNbuqrEx

## Key facts about Payment QR Codes
**As described in Payment QR Code Specification from NBU (National Bank of Ukraine)**

QR Code establishes unified rules for QR code formation and usage for credit transfers in Ukraine and aims to improve payment convenience. Usage of Payment QR Codes is unified but not mandatory for payment participants

### Key Technical Parameters

- Uses UTF-8 or Win1251 encoding for Cyrillic characters
- ISO 646 for non-Cyrillic characters
- Error correction levels: M (15%) or L (7%)
- Maximum QR code version: 15 (77 modules) for format 002

### Mandatory Data Elements

- Service mark ("BCD")
- Format version
- Encoding type
- Function code ("UCT" - Ukrainian Credit Transfer)
- Recipient information
- Account number
- Recipient code (EDRPOU/passport/tax number)
- Payment purpose

### Optional Elements

- Amount/currency (UAH only)
- Display text
- Reference number
- Some reserved fields for future use

### Implementation Details

- Each field is separated by line endings (LF or CR+LF)
- Minimum recommended module size is 0.5mm for proper scanning
- QR codes can be printed on invoices or displayed electronically
- Can be scanned using device cameras, payment apps, or specialized banking equipment

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ukraine_nbuqr` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ukraine_nbuqr, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ukraine_nbuqr_ex>.
