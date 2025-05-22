#!/bin/bash
VERSION=1.04
# Function to display the calculator interface
display_calculator() {
    clear
    echo "============================="
    echo "      Bash Calculator      "
    echo "============================="
    echo "Current Expression: $current_expression"
    echo "-----------------------------"
    echo "   Numbers:      Operators:"
    echo "   1. 0          11. +"
    echo "   2. 1          12. -"
    echo "   3. 2          13. *"
    echo "   4. 3          14. /"
    echo "   5. 4          15. % (Modulus)"
    echo "   6. 5          16. ( (Parenthesis)"
    echo "   7. 6          17. ) (Parenthesis)"
    echo "   8. 7"
    echo "   9. 8"
    echo "  10. 9"
    echo "-----------------------------"
    echo "   18. Clear"
    echo "   19. Calculate"
    echo "   20. Exit"
    echo "============================="
    echo -n "Enter your choice: "
}

# Initialize variables
current_expression=""
result=""

# Main calculator loop
while true; do
    display_calculator
    read choice

    case $choice in
        1) current_expression+="0" ;;
        2) current_expression+="1" ;;
        3) current_expression+="2" ;;
        4) current_expression+="3" ;;
        5) current_expression+="4" ;;
        6) current_expression+="5" ;;
        7) current_expression+="6" ;;
        8) current_expression+="7" ;;
        9) current_expression+="8" ;;
        10) current_expression+="9" ;;
        11) current_expression+="+" ;;
        12) current_expression+="-" ;;
        13) current_expression+="*" ;;
        14) current_expression+="/" ;;
        15) current_expression+="%" ;;
        16) current_expression+="(" ;;
        17) current_expression+=")" ;;
        18) # Clear
            current_expression=""
            result=""
            echo "Expression cleared."
            sleep 1
            ;;
        19) # Calculate
            if [[ -z "$current_expression" ]]; then
                echo "No expression to calculate."
                sleep 1
            else
                # Use bc for floating point arithmetic
                # Added error handling for invalid expressions
                result=$(echo "scale=4; $current_expression" | bc -l 2>/dev/null)
                if [[ $? -ne 0 || -z "$result" ]]; then
                    echo "Error: Invalid expression or division by zero."
                    result="Error"
                else
                    echo "Result: $result"
                fi
                current_expression="$result" # Set the result as the new expression for chained operations
                sleep 2
            fi
            ;;
        20) # Exit
            echo "Exiting calculator. Goodbye!"
            break
            ;;
        *)
            echo "Invalid choice. Please try again."
            sleep 1
            ;;
    esac
done
