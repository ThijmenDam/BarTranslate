import styled from 'styled-components';

export const HeaderStyle = styled.div`
  padding-left: 20px;
  padding-right: 18px;
  min-height: 40px;
  max-height: 40px;
  background-color: #5c94f5;
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
`;

export const TitleStyle = styled.span`
  user-select: none;
  color: #f1f1f1;
  font-size: 14px;
`;

export const IconStyle = styled.div`
  height: 18px;
  width: 18px;
  
  display: flex;
  justify-content: center;
  align-items: center;
`;

export const IconsContainerStyle = styled.div`
  display: flex;
  width: 44px;
  justify-content: space-between;
  
  svg {
    max-height: 14px!important;
    transition: color ease-in-out 100ms;
    
    &:hover {
      color: #fff;
    }
  }
`;
