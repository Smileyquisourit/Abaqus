# Chart Class - MATLAB

The `Chart` class provides a way to represent and work with a table-based abaque (chart) from a CSV file. It offers functionality to read the CSV, access column names, and interpolate values from the table.

## Features

- **Load CSV File**: Reads a CSV file and stores it as a table.
- **Interpolation**: Supports linear interpolation between rows when an exact match for a value is not found in the table.

## Table of Contents

- [Chart Class - MATLAB](#chart-class---matlab)
  - [Features](#features)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Creating a Chart](#creating-a-chart)
    - [Accessing Column Names](#accessing-column-names)
    - [Interpolating Values](#interpolating-values)
  - [Methods](#methods)
    - [Public Methods](#public-methods)
  - [Exemple](#exemple)
  - [License](#license)

## Installation

1. Copy the `Chart.m` file into your MATLAB working directory.
2. Ensure your CSV file is accessible in the working directory or provide an absolute path.

If you want to create a package from it, copy the `Chart.m` file in a package folder (for exemple `+Chart`) and import it with `import Chart.Chart` or `import Chart.*`

## Usage

### Creating a Chart

To create an instance of the `Chart` class, provide the path to a CSV file:

```matlab
import Chart.*
chart = Chart('path_to_file.csv');
```

This function use the function `readtable` for reading the csv file, and have a `varargin` argument, so you can pass all the possible argument that you want to the `readtable` function.

### Accessing Column Names

You can retrieve the column names from the table using the col_names property:
```matlab
columnNames = chart.col_names;
```

### Interpolating Values

The `interpolate` method allows you to retrieve or interpolate rows from the table based on a specified value:

```matlab
result = chart.interpolate(15, 'from', "Var1", 'method', "linear");
```

**Optional Arguments**
- `variables` Specify which variables (columns) to return. If not provided, all columns will be returned.
- `from` The variable (column) from which the interpolation is based. Defaults to the first column.
- `as_table` Set to true to return the result as a table, otherwise the result will be a numeric array (default to false).
- `method` The interpolation method. Currently, only "linear" is supported.


## Methods

### Public Methods

- `Chart(path)` Constructor. Loads the CSV data into a table.
- `interpolate(x, options)` Interpolates the data for the given value x based on the column specified in options.from. Can return either a table or a numeric array.

## Exemple

This is a complete example of how to use the `Chart` class:
```matlab
% Create a Chart object by loading a CSV file
import Chart.*
chart = Chart('data.csv');

% Display available column names
disp(chart.col_names);

% Interpolate a value from the table, using 'Var1' for interpolation
result = chart.interpolate(15, 'from', "Var1", 'variables', ["Var2", "Var3"], 'method', "linear");

% Display the interpolated result
disp(result);
```

## License

This project is open source and freely available for use.