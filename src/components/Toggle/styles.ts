import styled from 'styled-components';

// Toggle based on https://www.youtube.com/watch?v=N8BZvfRD_eU

export const ToggleStyle = styled.div`
  
  width: 100%;
  
  input {
    opacity: 0;
    position: absolute;
    left: -9000px;
    top: -9000px;
  }

  input + label {
    position: relative;
    display: flex;
    align-items: center;
    cursor: pointer;
    font-size: 14px;
    user-select: none;
  }
  
  input + label::before {
    content: "";
    width: 2.6em;
    height: 1.3em;
    background-color: hsl(0, 80%, 90%);
    border-radius: 1em;
    transition: background-color 200ms ease-in-out;
    
    position: absolute;
    right: 0;
  }

  input + label::after {
    display: flex;
    justify-content: center;
    align-items: center;
    position: absolute;
    content: "\\2715";
    font-size: .65em;
    right: 2em;
    width: 1.8em;
    height: 1.8em;
    background-color: hsl(0, 80%, 60%);
    color: white;
    border-radius: 1em;
    transition: background-color 200ms ease-in-out, transform 200ms ease-in-out;
  }
  
  input:checked + label::before {
    background-color: hsl(100, 70%, 90%);
  }
  
  input:checked + label::after {
    content: "\\2713";
    transform: translateX(100%);
    background-color: hsl(100, 70%, 60%);
  }

  input:disabled + label {
    pointer-events: none;
    //color: #777;
  }

  input:disabled + label::before {
    background-color: #CCC;
  }

  input:disabled + label::after {
    background-color: #777;
  }
`;
