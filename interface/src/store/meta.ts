import { PublicState, PolicyState, TagsState } from "@/types";

export default {
  namespaced: true,
  state() {
    return {
      public: [] as PublicState,
      policy: [] as PolicyState,
      tags: [] as TagsState,
    };
  },

  getters: {
    //agentSubscriptions(state): Array<AgentSubscription> | [] {
    //return state.subscriptions
    //},
  },

  mutations: {
    setPublic(state, payload: PublicState) {
      state.public = payload;
    },
    setPolicy(state, payload: PolicyState) {
      state.policy = payload;
    },
    setTags(state, payload: TagsState) {
      state.tags = payload;
    },
    //addSubscription(state, payload: AgentSubscription) {
    //state.subscriptions.push(payload);
    //},

    //unsetSubscription(state, subscription: AgentSubscription) {
    //const sub = state.subscriptions.find((s) => s === subscription);
    //state.subscriptions = state.subscriptions.filter((s) => s != sub);
    // },
  },

  actions: {
    handleSubscriptionData(
      { commit, dispatch },
      payload: {
        public: PublicState;
        policy: PolicyState;
        tags: TagsState;
      }
    ) {
      console.log("in meta ", payload);

      commit("setPublic", payload.public);
      commit("setPolicy", payload.policy);
      commit("setTags", payload.tags);
    },
  },
};
