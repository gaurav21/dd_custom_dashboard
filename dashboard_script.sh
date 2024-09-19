#!/bin/bash

# Check if input and output file parameters are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 input.csv output.json"
  exit 1
fi

input_file="$1"
output_file="$2"

# Initialize the JSON structure with an empty array
echo "[" > "$output_file"

# Read the CSV file line by line
while IFS=, read -r xx; do
  # Trim any whitespace around the value of xx
  trimmed_xx1=$(echo "$xx" | xargs)
  trimmed_xx=$(echo "$trimmed_xx1" | sed 's/^[ \t]*//;s/[ \t]*$//')
  #echo ${trimmed_xx}
  #param_added="{*}.as_count()"
  # echo $trimmed_xx
  #query_param="${trimmed_xx}.as_count()"

  #echo ${query_param}

  # Create the JSON structure
  json_object=$(cat <<EOF
{
  "definition": {
    "title": "",
    "title_size": "16",
    "title_align": "left",
    "show_legend": true,
    "legend_layout": "auto",
    "legend_columns": ["avg", "min", "max", "value", "sum"],
    "type": "timeseries",
    "requests": [
      {
        "formulas": [
          {
            "formula": "query1"
          }
        ],
        "queries": [
          {
            "name": "query1",
            "data_source": "metrics",
            "query": "sum:$trimmed_xx~~~{*}.as_count()"
          }
        ],
        "response_format": "timeseries",
        "style": {
          "palette": "dog_classic",
          "order_by": "values",
          "line_type": "solid",
          "line_width": "normal"
        },
        "display_type": "line"
      }
    ]
  }
}
EOF
)

  # Append the JSON object to the output file
  echo "$json_object," >> "$output_file"

done < "$input_file"

# Remove the last trailing comma from the JSON output and close the JSON array
sed -i '$ s/,$//' "$output_file"
echo "]" >> "$output_file"

echo "JSON saved to $output_file"