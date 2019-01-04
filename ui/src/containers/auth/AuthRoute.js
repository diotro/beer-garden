import React from "react";
import { Route, Redirect, withRouter } from "react-router-dom";
import PropTypes from "prop-types";
import { connect } from "react-redux";
import { compose } from "recompose";

export const AuthRoute = ({
  component: Component,
  render,
  authEnabled,
  isAuthenticated,
  ...rest
}) => {
  let renderMethod;

  if (authEnabled && !isAuthenticated) {
    renderMethod = props => {
      return (
        <Redirect
          to={{ pathname: "/login", state: { from: props.location } }}
        />
      );
    };
  } else if (render) {
    renderMethod = render;
  } else {
    renderMethod = props => {
      return <Component {...props} />;
    };
  }

  return <Route {...rest} render={renderMethod} />;
};

AuthRoute.propTypes = {
  authEnabled: PropTypes.bool.isRequired,
  isAuthenticated: PropTypes.bool.isRequired,
};

const mapStateToProps = state => {
  return {
    isAuthenticated: state.authReducer.isAuthenticated,
    authEnabled: state.configReducer.config.authEnabled,
  };
};

const enhance = compose(
  connect(mapStateToProps),
  withRouter,
);

export default enhance(AuthRoute);
