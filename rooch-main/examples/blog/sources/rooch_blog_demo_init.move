// Copyright (c) RoochNetwork
// SPDX-License-Identifier: Apache-2.0

// <autogenerated>
//   This file was generated by dddappp code generator.
//   Any changes made to this file manually will be lost next time the file is regenerated.
// </autogenerated>

module rooch_examples::rooch_blog_demo_init {
    
    use rooch_examples::article;

    public entry fun initialize(account: &signer) {
        article::initialize(account);
    }

}