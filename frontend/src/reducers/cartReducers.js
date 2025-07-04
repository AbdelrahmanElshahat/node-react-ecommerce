import { CART_ADD_ITEM, CART_REMOVE_ITEM, CART_SAVE_SHIPPING, CART_SAVE_PAYMENT } from "../constants/cartConstants";

function cartReducer(state = { cartItems: [], shipping: {}, payment: {} }, action) {
  switch (action.type) {
    case CART_ADD_ITEM:
      const item = action.payload;
      if (!item || !item.product) {
        // If the item is invalid, return the current state
        return state;
      }
      
      const product = state.cartItems.find(x => x.product === item.product);
      if (product) {
        return {
          ...state,
          cartItems: state.cartItems.map(x => x.product === product.product ? item : x)
        };
      }
      return { ...state, cartItems: [...state.cartItems, item] };
      
    case CART_REMOVE_ITEM:
      if (!action.payload) {
        // If the product ID is invalid, return the current state
        return state;
      }
      return { 
        ...state, 
        cartItems: state.cartItems.filter(x => x.product !== action.payload) 
      };
    case CART_SAVE_SHIPPING:
      return { 
        ...state, 
        shipping: action.payload || {} 
      };
      
    case CART_SAVE_PAYMENT:
      return { 
        ...state, 
        payment: action.payload || {} 
      };
      
    default:
      return state;
  }
}

export { cartReducer }